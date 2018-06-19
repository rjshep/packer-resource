# Packer Build Resource

A Concourse CI resource to build new [Amazon Machine Images (AMI) via Packer](https://www.packer.io/docs/builders/amazon.html)

## Source Configuration

- `region` (optional string): The AWS region to work in - defaults to AWS_REGION environment variable
- `owners` (optional list): The list of owners to use when searching for AMI during check
- `executable_users` (optional list): The list of executable users to use when searching for AMI during check
- `filters` (optional map): The [filters](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html) to match when searching for AMI during check

## Behaviour

### `check`: Check for new versions of an AMI

Returns an ordered list of versions that match the criteria specified in the source.  This can be used to trigger a new build when an AMI is updated.

### `in`: Get metadata about an AMI

Provides 3 files:
- `version.txt` - a text file containing the selected AMI id
- `version.json` - a JSON file containing the selected AMI id in the `ami` field
- `image.json` - the AWS [metadata](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html) for the selected AMI

### `out`: Build a new AMI

#### Parameters
- `template` (required string): The path to the packer template.
- `var_file` (optional string or list): The path or list of paths to a [external JSON variable file](https://www.packer.io/docs/templates/user-variables.html).

All other parameters will be passed through to packer as variables.

## Example

```yaml
resource_types:
- name: packer
  type: docker-image
  source:
    repository: subnova/packer-resource

resources:
- name: base-ami
  type: packer
  source:
    region: eu-west-1
    owners: ["12345678"]
    filters:
      name: ["Ubuntu *"]
      "tag:System": ["packer"]

- name: created-ami
  type: packer
  source:
    region: eu-west-1
    owners: [self]
    filters:
      name: ["My amazing AMI *"]

- name: my-ami-source
  type: git
  source:
    uri: https://github.com/abc/repo

jobs:
- name: my-ami
  plan:
  - get: my-ami-source
    trigger: true
  - get: base-ami
    trigger: true
  - put: created-ami
    params:
      template: my-ami-source/packer_template.json
      var_file:
        - base-ami/version.json
        - my-ami-source/packer_params.json
  ```
