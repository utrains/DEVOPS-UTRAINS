module "jenkins" {
  source            = "../ami-jenkins-jfrog"
  aws_region        = "us-east-1"
  aws_instance_type = "t2.medium"
  aws_key           = "jenkins-jgrog-key1"
  qa_server         = false
  jfrog_server      = true
  profile           = "default"
  jenkins_ami       = "ami-0651a24cc46a968a0"
  jfrog_ami         = "ami-0aca76f2fc36ba481"
  role_name         = "jenkinsAdminRoleAmi1"
  qa_uat_sg_name    = "qa-uat-security-group"
  jenkins_sg_name   = "jenkins-security-group"
  jfrog_sg_name     = "jfrog-security-group"
}

