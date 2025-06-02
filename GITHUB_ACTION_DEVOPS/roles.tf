resource "aws_iam_role" "jenkins_admin_role" {
  name = "cicd_lab_admin_role_test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
       {
        Effect = "Allow",
        Principal = {
          Service = "ecr.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_policy_attachment" {
  role       = aws_iam_role.jenkins_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = aws_iam_role.jenkins_admin_role.name
  role = aws_iam_role.jenkins_admin_role.name
}