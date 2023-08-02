FROM amazon/aws-cli:2.0.43

RUN yum install -y jq gzip nano tar git unzip wget

RUN curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/0.13.1/terraform_0.13.1_linux_amd64.zip
RUN unzip /tmp/terraform.zip
RUN chmod +x terraform && mv terraform /usr/local/bin/