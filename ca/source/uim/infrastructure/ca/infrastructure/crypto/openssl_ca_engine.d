/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.infrastructure.crypto.openssl_ca_engine;

import std.file : readText, write, rmdirRecurse, mkdirRecurse;
import std.path : buildPath;
import std.process : execute, Config;
import std.random : uniform;
import std.string : splitLines, startsWith, replace;
import std.array : join;
import uim.infrastructure.ca.domain.ports.crypto.ca_engine : ICaCryptoEngine, RootCaMaterial, IssuedCertMaterial;

class OpenSslCaEngine : ICaCryptoEngine {
    override RootCaMaterial createRootCa(string commonName, uint validDays) {
        auto workDir = createWorkDir();
        scope (exit) cleanup(workDir);

        auto safeCn = sanitizeCommonName(commonName);
        auto keyPath = buildPath(workDir, "ca.key");
        auto certPath = buildPath(workDir, "ca.crt");

        runOpenSsl(["genrsa", "-out", keyPath, "4096"], workDir);
        runOpenSsl([
            "req", "-x509", "-new", "-nodes",
            "-key", keyPath,
            "-sha256",
            "-days", uintToString(validDays),
            "-subj", "/CN=" ~ safeCn,
            "-out", certPath
        ], workDir);

        auto certPem = readText(certPath);
        auto keyPem = readText(keyPath);
        auto serial = readSerial(certPath, workDir);

        return RootCaMaterial(certPem, keyPem, serial);
    }

    override IssuedCertMaterial issueCertificate(
        string caCertPem,
        string caKeyPem,
        string commonName,
        string[] subjectAltNames,
        uint validDays
    ) {
        auto workDir = createWorkDir();
        scope (exit) cleanup(workDir);

        auto safeCn = sanitizeCommonName(commonName);

        auto caCertPath = buildPath(workDir, "ca.crt");
        auto caKeyPath = buildPath(workDir, "ca.key");
        auto leafKeyPath = buildPath(workDir, "tls.key");
        auto leafCsrPath = buildPath(workDir, "tls.csr");
        auto leafCertPath = buildPath(workDir, "tls.crt");
        auto extPath = buildPath(workDir, "leaf-ext.cnf");

        write(caCertPath, caCertPem);
        write(caKeyPath, caKeyPem);

        runOpenSsl(["genrsa", "-out", leafKeyPath, "2048"], workDir);
        runOpenSsl([
            "req", "-new",
            "-key", leafKeyPath,
            "-subj", "/CN=" ~ safeCn,
            "-out", leafCsrPath
        ], workDir);

        string[] signArgs = [
            "x509", "-req",
            "-in", leafCsrPath,
            "-CA", caCertPath,
            "-CAkey", caKeyPath,
            "-CAcreateserial",
            "-out", leafCertPath,
            "-days", uintToString(validDays),
            "-sha256"
        ];

        if (subjectAltNames.length > 0) {
            auto sanLine = buildSanLine(subjectAltNames);
            auto extBody = "[v3_req]\nsubjectAltName=" ~ sanLine ~ "\n";
            write(extPath, extBody);
            signArgs ~= ["-extfile", extPath, "-extensions", "v3_req"];
        }

        runOpenSsl(signArgs, workDir);

        auto certPem = readText(leafCertPath);
        auto keyPem = readText(leafKeyPath);
        auto chainPem = certPem ~ "\n" ~ caCertPem;
        auto serial = readSerial(leafCertPath, workDir);

        return IssuedCertMaterial(certPem, keyPem, chainPem, serial);
    }

    private string createWorkDir() {
        auto suffix = uintToString(uniform(100000u, 999999u));
        auto path = buildPath("/tmp", "uim-ca-" ~ suffix);
        mkdirRecurse(path);
        return path;
    }

    private void cleanup(string path) {
        try {
            rmdirRecurse(path);
        } catch (Exception) {
        }
    }

    private void runOpenSsl(string[] args, string workDir) {
        auto cmd = ["openssl"] ~ args;
        auto result = execute(cmd, null, Config.none, size_t.max, workDir);
        if (result.status != 0) {
            throw new Exception("openssl command failed: " ~ result.output);
        }
    }

    private string readSerial(string certPath, string workDir) {
        auto result = execute(
            ["openssl", "x509", "-in", certPath, "-noout", "-serial"],
            null,
            Config.none,
            size_t.max,
            workDir
        );
        if (result.status != 0) {
            throw new Exception("failed to read certificate serial: " ~ result.output);
        }

        foreach (line; result.output.splitLines()) {
            if (line.startsWith("serial=")) {
                return line[7 .. $].idup;
            }
        }
        return "";
    }

    private string buildSanLine(string[] subjectAltNames) {
        string[] entries;
        foreach (san; subjectAltNames) {
            auto clean = sanitizeDnsLabel(san);
            if (clean.length > 0) {
                entries ~= "DNS:" ~ clean;
            }
        }
        return entries.join(",");
    }

    private string sanitizeCommonName(string value) {
        auto v = value.replace("/", "-");
        if (v.length == 0) return "cluster.local";
        return v;
    }

    private string sanitizeDnsLabel(string value) {
        auto v = value.replace(",", "").replace(" ", "").replace("/", "-");
        return v;
    }

    private string uintToString(uint value) {
        import std.conv : to;
        return value.to!string;
    }
}
