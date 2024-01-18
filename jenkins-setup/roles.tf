resource "aws_iam_role" "jenkins_admin_role" {
  name = "jenkinsAdminRole"

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
  name = "jenkinsAdminRole"
  role = aws_iam_role.jenkins_admin_role.name
}