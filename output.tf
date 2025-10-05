output "instanceid" {
  value = aws_instance.ec2.*.id
}

output "public_ip" {
  value = aws_instance.ec2.*.public_ip
}

output "s3_bucket" {
  value = aws_s3_bucket.images.bucket
}
