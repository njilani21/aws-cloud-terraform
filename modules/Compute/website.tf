############################################
# STATIC SITE HOSTING - S3 + IAM for EC2
# Add this to modules/Compute/website.tf
############################################

# ---------------- S3 bucket to hold site files ----------------
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-website"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------- Upload every file in the site folder ----------------
# Point `website_source_dir` at your extracted site folder, e.g.
# "../website"

resource "aws_s3_object" "website_files" {
  for_each = fileset(var.website_source_dir, "**")

  bucket = aws_s3_bucket.website.id
  key    = each.value
  source = "${var.website_source_dir}/${each.value}"
  etag   = filemd5("${var.website_source_dir}/${each.value}")

  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      jpg  = "image/jpeg"
      png  = "image/png"
      svg  = "image/svg+xml"
      ico  = "image/x-icon"
      woff = "font/woff"
      woff2 = "font/woff2"
      ttf  = "font/ttf"
      eot  = "application/vnd.ms-fontobject"
      otf  = "font/otf"
    },
    lower(regex("\\.([^.]+)$", each.value)[0]),
    "application/octet-stream"
  )
}

# ---------------- IAM Role for EC2 to read the S3 bucket ----------------
resource "aws_iam_role" "ec2_website" {
  name = "${var.project_name}-ec2-website-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_s3_read" {
  name = "${var.project_name}-ec2-s3-read"
  role = aws_iam_role.ec2_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.website.arn,
        "${aws_s3_bucket.website.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_website" {
  name = "${var.project_name}-ec2-website-profile"
  role = aws_iam_role.ec2_website.name
}
