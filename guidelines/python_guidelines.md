# AWS Python & boto3 Best Practices Guide

## Table of Contents

- [AWS SDK (boto3) Optimization](#aws-sdk-boto3-optimization)
- [Python Code Standards](#python-code-standards)
- [Security Best Practices](#security-best-practices)
- [Packaging and Deployment](#packaging-and-deployment)
- [Monitoring & Observability](#monitoring--observability)
- [Error Handling](#error-handling)
- [Performance Optimization](#performance-optimization)
- [Lambda-Specific Best Practices](#lambda-specific-best-practices)
- [Docker Best Practices](#docker-best-practices)
- [Testing and Validation](#testing-and-validation)

## AWS SDK (boto3) Optimization

### Connection Management

- **Use connection pooling** for performance optimization with adaptive attempts and timeouts
- **Move AWS clients outside the handler function** to avoid reinitialization during subsequent invocations
- **Configure retry logic** with exponential backoff and configurable constants for better control
- **Use session objects** for better connection management:

  ```python
  # Good: Reuse session
  session = boto3.Session()
  s3_client = session.client('s3')

  # Avoid: Creating new clients repeatedly
  # s3_client = boto3.client('s3')  # Don't do this in loops
  ```

### Resource Configuration

- **Enable encryption (KMS)** whenever possible for data at rest and in transit
- **Implement versioning** for S3 buckets and other applicable resources
- **Configure lifecycle policies** for cost optimization and compliance
- **Use resource-based policies** to control access at the resource level

### Data Handling

- **Use paginators** for operations that return large datasets:

  ```python
  paginator = s3_client.get_paginator('list_objects_v2')
  for page in paginator.paginate(Bucket='my-bucket'):
      for obj in page.get('Contents', []):
          process_object(obj)
  ```

- **Use multipart uploads** for large files (>100MB) to improve throughput and resilience
- **Implement proper exception handling** for AWS-specific errors:

  ```python
  from botocore.exceptions import ClientError, BotoCoreError

  try:
      response = s3_client.get_object(Bucket='bucket', Key='key')
  except ClientError as e:
      if e.response['Error']['Code'] == 'NoSuchKey':
          logger.warning(f"Object not found: {key}")
      else:
          logger.error(f"AWS error: {e}")
  except BotoCoreError as e:
      logger.error(f"Boto core error: {e}")
  ```

## Python Code Standards

### Code Formatting and Style

- **Comply with PEP-8** (Python Enhancement Proposal 8) for consistent formatting
- **Use automated tools** for enforcement:
  - `black` for code formatting
  - `pylint` and `flake8` for linting
  - `isort` for import sorting
  - `mypy` for type checking

### Type Hints and Documentation

- **Add type hints** to all functions and variables (PEP-484):

  ```python
  from typing import Dict, List, Optional, Union

  def process_accounts(configs: List[Dict[str, Any]]) -> Optional[Dict[str, str]]:
      """Process account configurations and return results."""
      pass
  ```

- **Use descriptive docstrings** for classes, methods, and functions (PEP-257):

  ```python
  def assume_cross_account_role(
      account_id: str,
      role_name: str,
      session_name: str
  ) -> boto3.Session:
      """
      Assume a cross-account IAM role and return a session.

      Args:
          account_id: The AWS account ID containing the role
          role_name: The name of the IAM role to assume
          session_name: A unique name for the session

      Returns:
          A boto3 Session object with assumed role credentials

      Raises:
          ClientError: If role assumption fails
      """
      pass
  ```

### Object-Oriented Design

- **Use Abstract Base Classes (ABCs)** to define clear interfaces:

  ```python
  from abc import ABC, abstractmethod

  class BaseProcessor(ABC):
      @abstractmethod
      def execute(self) -> Dict[str, Any]:
          """Execute the processing logic."""
          pass
  ```

### Constants and Configuration

- **Define constants** at the top of modules:

  ```python
  # Configuration constants
  MAX_RETRY_ATTEMPTS = 3
  RETRY_BACKOFF_FACTOR = 2
  DEFAULT_TIMEOUT = 30

  # AWS Resource naming patterns
  DYNAMODB_TABLE_PREFIX = "iac-polyglot"
  S3_BUCKET_PATTERN = "{project_id}-{environment}-{region}"
  ```

## Security Best Practices

### Credential Management

- **Never hardcode credentials** in your application code
- **Use IAM roles** with least privilege principle:
  - Attach roles to EC2 instances, Lambda functions, or ECS tasks
  - Grant only permissions necessary for specific actions
  - Use condition-based policies when possible
- **Rotate credentials automatically** by relying on AWS SDKs for temporary credentials

### Secrets Management

- **Store sensitive information** in AWS Secrets Manager or Systems Manager Parameter Store:

  ```python
  def get_secret(secret_name: str, region: str) -> Dict[str, Any]:
      """Retrieve secret from AWS Secrets Manager."""
      client = boto3.client('secretsmanager', region_name=region)
      try:
          response = client.get_secret_value(SecretId=secret_name)
          return json.loads(response['SecretString'])
      except ClientError as e:
          logger.error(f"Failed to retrieve secret {secret_name}: {e}")
          raise
  ```

- **Define resource policies** for Secrets Manager to restrict access
- **Use environment variables** for non-sensitive configuration

### Data Protection

- **Enable encryption in transit and at rest**
- **Implement proper input validation and sanitization**
- **Use secure communication protocols** (HTTPS, TLS)

## Packaging and Deployment

### Environment Management

- **Use environment-specific configurations**:
  - AWS Parameter Store for runtime configuration
  - Secrets Manager for sensitive data
  - `.tfvars` files for infrastructure configuration
- **Implement proper dependency management**:

  ```bash
  # requirements.txt
  boto3>=1.26.0,<2.0.0
  pandas>=1.5.0,<2.0.0
  requests>=2.28.0,<3.0.0
  ```

### Package Optimization

- **Reduce package size** by including only essential libraries
- **Use lightweight runtimes** to reduce cold start times
- **Layer common dependencies** in Lambda layers for reuse

### Pre-deployment Validation

- **Lint and test** Lambda code locally before deployment:

  ```bash
  # Testing pipeline
  pytest tests/
  black --check .
  flake8 .
  mypy .
  ```

- **Use SAM CLI** or similar tools for local testing

## Monitoring & Observability

### Logging Standards

- **Use structured logging** (JSON format) for better analysis:

  ```python
  import json
  import logging
  from datetime import datetime

  class StructuredLogger:
      def __init__(self, name: str):
          self.logger = logging.getLogger(name)

      def info(self, message: str, **kwargs):
          log_entry = {
              "timestamp": datetime.utcnow().isoformat(),
              "level": "INFO",
              "message": message,
              **kwargs
          }
          self.logger.info(json.dumps(log_entry))
  ```

- **Use unique identifiers** (correlation IDs) to track related logs across services
- **Standardize log levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL

### Monitoring Setup

- **Enable CloudTrail** for API call auditing
- **Create CloudWatch Alarms** for error rate thresholds
- **Use EventBridge rules** for specific event notifications
- **Implement custom metrics** for business logic monitoring

## Error Handling

### Exception Hierarchy

- **Use specific exception handling** for different error types:

  ```python
  try:
      result = process_data()
  except ValidationError as e:
      logger.warning(f"Data validation failed: {e}")
      return {"statusCode": 400, "body": json.dumps({"error": str(e)})}
  except ClientError as e:
      error_code = e.response['Error']['Code']
      if error_code == 'Throttling':
          logger.warning("AWS API throttling detected, retrying...")
          # Implement retry logic
      else:
          logger.error(f"AWS client error: {e}")
          return {"statusCode": 500, "body": json.dumps({"error": "Internal error"})}
  except Exception as e:
      logger.error(f"Unexpected error: {e}", exc_info=True)
      return {"statusCode": 500, "body": json.dumps({"error": "Internal error"})}
  ```

### Response Standards

- **Return informative HTTP responses** with appropriate status codes
- **Distinguish between transient and permanent errors**
- **Implement circuit breaker patterns** for external service calls

## Performance Optimization

### Memory and CPU Management

- **Profile your code** to identify bottlenecks
- **Use appropriate data structures** for your use case
- **Implement caching strategies** where applicable
- **Optimize database queries** and API calls

### Concurrency and Parallelism

- **Use asyncio** for I/O-bound operations:

  ```python
  import asyncio
  import aioboto3

  async def process_multiple_accounts(account_configs: List[Dict]) -> List[Dict]:
      """Process multiple accounts concurrently."""
      tasks = [process_account(config) for config in account_configs]
      return await asyncio.gather(*tasks)
  ```

- **Implement proper thread safety** when using threading
- **Use connection pooling** for database connections

## Lambda-Specific Best Practices

### Cold Start Optimization

- **Initialize resources outside the handler**:

  ```python
  # Outside handler - initialized once
  s3_client = boto3.client('s3')
  secrets_cache = {}

  def lambda_handler(event, context):
      # Handler logic here
      pass
  ```

- **Use provisioned concurrency** for predictable latency
- **Optimize package size** and use layers

### Resource Management

- **Set appropriate timeout values**
- **Configure memory allocation** based on actual usage
- **Use environment variables** for configuration
- **Implement proper error handling** and logging

## Docker Best Practices

### Dockerfile Optimization

```dockerfile
# Use slim base images
FROM python:3.11-slim

# Set labels for documentation
LABEL maintainer="team@company.com"
LABEL description="Central to destination metadata processor"

# Create non-root user
RUN useradd --create-home --shell /bin/bash app

# Set working directory
WORKDIR /app

# Copy and install dependencies first (for layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=app:app . .

# Switch to non-root user
USER app

# Specify the Lambda handler
CMD ["central_to_dst_metadata.lambda_handler"]
```

### Build Process

- **Use multi-stage builds** for production optimization
- **Use .dockerignore** to exclude unnecessary files
- **Upload to Amazon ECR** for vulnerability scanning
- **Tag images** with version information

## Testing and Validation

### Unit Testing

```python
import pytest
from unittest.mock import Mock, patch
from moto import mock_s3, mock_sts

@mock_s3
@mock_sts
def test_cross_account_processing():
    """Test cross-account role assumption and processing."""
    # Setup mocks
    # Test logic
    # Assertions
    pass
```

### Integration Testing

- **Use AWS LocalStack** for local AWS service simulation
- **Test with realistic data** and scenarios
- **Validate error handling** paths

### Code Quality

- **Maintain test coverage** above 80%
- **Use mutation testing** for test quality validation
- **Implement code review** processes

---

## Quick Reference Checklist

### Before Deployment

- [ ] Code follows PEP-8 standards
- [ ] Type hints added to all functions
- [ ] Docstrings written for all classes and methods
- [ ] Unit tests written and passing
- [ ] Security scan completed
- [ ] Dependencies updated and secured
- [ ] Environment variables configured
- [ ] Logging implemented
- [ ] Error handling comprehensive

### Production Readiness

- [ ] Monitoring and alerting configured
- [ ] Backup and recovery procedures defined
- [ ] Performance benchmarks established
- [ ] Security policies reviewed
- [ ] Documentation updated
- [ ] Rollback procedures defined
