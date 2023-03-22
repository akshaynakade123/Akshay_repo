resource "aws_iam_user" "akki212" {
  name = "practice-purpose"
  path = "/system/"

  tags = {
    tag-key = "demo"
  }
}