module vpc_service.application.usecases.create_subnet;

import vpc_service.application.dto.vpc_commands : CreateSubnetCommand;
import vpc_service.domain.entities.subnet : Subnet, SubnetState;
import vpc_service.domain.ports.repositories.subnet : ISubnetRepository;
import vpc_service.domain.ports.repositories.vpc : IVpcRepository;

class CreateSubnetUseCase {
    private IVpcRepository vpcRepository;
    private ISubnetRepository subnetRepository;

    this(IVpcRepository vpcRepository, ISubnetRepository subnetRepository) {
        this.vpcRepository    = vpcRepository;
        this.subnetRepository = subnetRepository;
    }

    Subnet execute(in CreateSubnetCommand command) {
        enforceCommand(command);

        auto vpc = vpcRepository.findById(command.vpcId);
        if (vpc is null) {
            throw new Exception("VPC not found: " ~ command.vpcId);
        }

        auto subnet = Subnet(
            command.id,
            command.vpcId,
            command.name,
            command.cidr,
            command.availabilityZone,
            SubnetState.available
        );

        subnetRepository.save(subnet);
        return subnet;
    }

    private void enforceCommand(in CreateSubnetCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        if (command.vpcId.length == 0) {
            throw new Exception("vpcId must not be empty");
        }
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
        if (command.cidr.length == 0) {
            throw new Exception("cidr must not be empty");
        }
        if (command.availabilityZone.length == 0) {
            throw new Exception("availabilityZone must not be empty");
        }
    }
}
