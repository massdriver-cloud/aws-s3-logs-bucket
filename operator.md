## AWS S3 Logs Bucket

Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance. This guide helps you manage an S3 bucket tailored for logs storage, emphasizing security, management, and lifecycle policies.

### Design Decisions

- **Bucket Security**: ACLs are disabled to enforce bucket owner control and public access is blocked.
- **Server-Side Encryption**: Using AWS KMS for secure object storage, with optional user-managed keys.
- **Lifecycle Policies**: Supports transition to different storage classes and automated expiration.
- **Access Logging**: Optional configuration for logging access requests, with lifecycle configuration for efficient log management.

## Runbook

### Checking Bucket Existence

Ensure the S3 bucket exists.

```sh
aws s3api head-bucket --bucket <bucket-name>
```

If the bucket exists, the command will not return an error. If it does not, you will receive a `404 Not Found` error.

### Verifying Bucket Policies

Check the bucket policies to ensure proper permissions are set.

```sh
aws s3api get-bucket-policy --bucket <bucket-name>
```

Review the output JSON to verify access permissions.

### Testing Bucket Access

Verify you have the correct permissions to read from the bucket.

```sh
aws s3 ls s3://<bucket-name>
```

This command lists the contents of the bucket. If you do not have the correct permissions, you will receive an error.

### Enabling Server-Side Encryption

Ensure that server-side encryption is enabled on the bucket.

```sh
aws s3api get-bucket-encryption --bucket <bucket-name>
```

The output will show if and what kind of server-side encryption is enabled. If not enabled, follow the instructions in your organization to secure data at rest.

### Lifecycle Policy Issues

Check if lifecycle policies are properly configured.

```sh
aws s3api get-bucket-lifecycle-configuration --bucket <bucket-name>
```

Review the lifecycle policies in place and ensure they match intended configurations.

### Troubleshooting Access Logs

If access logs are not being generated, check the logging configuration.

```sh
aws s3api get-bucket-logging --bucket <bucket-name>
```

Ensure that `TargetBucket` and `TargetPrefix` are correctly set.

### KMS Key Misconfiguration

Check if the KMS key is properly associated with the bucket.

```sh
aws kms describe-key --key-id <key-id>
```

Ensure that the key policy allows S3 to use the key for encryption and decryption.

### Verifying IAM Policies

Ensure IAM policies are properly set for the users or roles accessing the bucket.

```sh
aws iam list-attached-user-policies --user-name <username>
```

or

```sh
aws iam list-attached-role-policies --role-name <rolename>
```

Inspect the listed policies to confirm that necessary S3 permissions are granted.

