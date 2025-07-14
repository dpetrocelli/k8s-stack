# AWS Architecture & Development Guidelines

## Table of Contents

- [1. AWS Well-Architected Framework Overview](#1-aws-well-architected-framework-overview)
- [2. Security Best Practices](#2-security-best-practices)
- [3. Operational Excellence](#3-operational-excellence)
- [4. Reliability](#4-reliability)
- [5. Performance Efficiency](#5-performance-efficiency)
- [6. Cost Optimization](#6-cost-optimization)
- [7. Sustainability](#7-sustainability)
- [8. Service-Specific Best Practices](#8-service-specific-best-practices)
- [9. Migration & Operations](#9-migration--operations)
- [10. Monitoring & Observability](#10-monitoring--observability)
- [11. Automation & DevOps](#11-automation--devops)
- [12. Quick Reference Checklists](#12-quick-reference-checklists)
- [13. Lambda Development Best Practices](#13-lambda-development-best-practices)
- [14. Cross-Account Architecture Patterns](#14-cross-account-architecture-patterns)
- [15. Infrastructure as Code (IaC) Development](#15-infrastructure-as-code-iac-development)
- [16. Migration-Specific Patterns](#16-migration-specific-patterns)
- [17. Data Processing & ETL Best Practices](#17-data-processing--etl-best-practices)
- [18. Event-Driven Architecture](#18-event-driven-architecture)
- [19. Code Quality & Testing](#19-code-quality--testing)
- [20. Deployment Pipelines for IaC](#20-deployment-pipelines-for-iac)

---

## 1. AWS Well-Architected Framework Overview

The AWS Well-Architected Framework provides architectural best practices across six pillars for designing and operating reliable, secure, efficient, cost-effective, and sustainable systems in the cloud.

### The Six Pillars

#### 1.1 Operational Excellence

- **Focus**: Running and monitoring systems to deliver business value and continuous improvement
- **Key Areas**: Organization, Prepare, Operate, Evolve

#### 1.2 Security

- **Focus**: Protecting data, systems, and assets through risk assessments and mitigation strategies
- **Key Areas**: Identity and Access Management, Detective Controls, Infrastructure Protection, Data Protection

#### 1.3 Reliability

- **Focus**: Ensuring workloads perform their intended functions correctly and consistently
- **Key Areas**: Foundations, Workload Architecture, Change Management, Failure Management

#### 1.4 Performance Efficiency

- **Focus**: Using IT and computing resources efficiently
- **Key Areas**: Selection, Review, Monitoring, Tradeoffs

#### 1.5 Cost Optimization

- **Focus**: Running systems to deliver business value at the lowest price point
- **Key Areas**: Practice Cloud Financial Management, Expenditure and Usage Awareness, Cost-Effective Resources

#### 1.6 Sustainability

- **Focus**: Minimizing environmental impacts of running cloud workloads
- **Key Areas**: Region Selection, User Behavior Patterns, Software and Architecture Patterns

### General Design Principles

```yaml
Core Principles:
  - Stop guessing your capacity needs
  - Test systems at production scale
  - Automate to make architectural experimentation easier
  - Allow for evolutionary architectures
  - Drive architectures using data
  - Improve through game days
```

---

## 2. Security Best Practices

### 2.1 Identity and Access Management (IAM)

#### Human Users

```yaml
Best Practices:
  Federation:
    - Use AWS IAM Identity Center for centralized access management
    - Require federation with identity providers for human users
    - Use temporary credentials instead of long-term access keys
    - Implement Single Sign-On (SSO) where possible

  Multi-Factor Authentication:
    - Require MFA for all human users
    - Use hardware MFA devices for highly privileged accounts
    - Enable MFA for root user accounts
```

#### Workloads and Applications

```yaml
Service Credentials:
  - Use IAM roles for EC2 instances, Lambda functions, and containers
  - Implement cross-account access using IAM roles and STS
  - Use temporary credentials for workloads outside AWS
  - Leverage IAM Roles Anywhere for on-premises workloads
```

#### Least Privilege Access

```yaml
Implementation:
  - Start with AWS managed policies, then move to custom policies
  - Use IAM Access Analyzer to generate least-privilege policies
  - Implement condition-based policies for additional security
  - Regular review and removal of unused permissions
  - Use permission boundaries for delegated administration
```

#### Policy Management

```yaml
Best Practices:
  - Use policy conditions to restrict access (IP, time, MFA, etc.)
  - Validate policies using IAM Access Analyzer
  - Implement Service Control Policies (SCPs) for organizational guardrails
  - Use Resource Control Policies (RCPs) for resource-level guardrails
```

### 2.2 Root User Security

```yaml
Root User Protection:
  - Enable MFA on root user account
  - Use root user only for tasks that require it
  - Store root user credentials securely
  - Monitor root user activity with CloudTrail
  - Consider using hardware MFA device for root user
  - Remove root user access keys if they exist
```

### 2.3 Data Protection

#### Encryption

```yaml
Encryption Standards:
  At Rest:
    - Enable encryption for all data stores (S3, EBS, RDS, etc.)
    - Use AWS KMS for key management
    - Implement envelope encryption for large datasets
    - Use customer-managed keys where appropriate

  In Transit:
    - Use TLS 1.2 or higher for all communications
    - Implement end-to-end encryption
    - Use VPC endpoints to keep traffic within AWS network
    - Enable encryption for inter-service communication
```

#### Key Management

```yaml
KMS Best Practices:
  - Use separate keys for different environments
  - Implement key rotation policies
  - Use grants for temporary access
  - Monitor key usage with CloudTrail
  - Implement cross-region key replication for DR
```

### 2.4 Network Security

```yaml
VPC Configuration:
  - Use private subnets for application and database tiers
  - Implement network segmentation using multiple VPCs
  - Use Security Groups as firewalls for instances
  - Implement NACLs for subnet-level security
  - Enable VPC Flow Logs for monitoring

Security Groups:
  - Follow principle of least privilege
  - Use descriptive names and tags
  - Reference other security groups instead of IP ranges
  - Regularly audit and clean up unused rules
  - Document the purpose of each rule
```

### 2.5 Monitoring and Detection

```yaml
Security Monitoring:
  - Enable AWS CloudTrail in all regions
  - Use AWS Config for compliance monitoring
  - Implement AWS GuardDuty for threat detection
  - Use AWS Security Hub for security posture management
  - Enable AWS Inspector for vulnerability assessments

  Alerting:
    - Set up CloudWatch alarms for security events
    - Use EventBridge for automated responses
    - Implement security incident response procedures
    - Regular security reviews and assessments
```

---

## 3. Operational Excellence

### 3.1 Organization and Culture

```yaml
Organizational Principles:
  - Implement Infrastructure as Code (IaC)
  - Automate operational processes
  - Make frequent, small, reversible changes
  - Refine operations procedures frequently
  - Anticipate failure scenarios
  - Learn from all operational failures
```

### 3.2 Infrastructure as Code

#### Terraform Best Practices

```hcl
# Project Structure
project_root/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── storage/
├── policies/
└── scripts/

# Best Practices
resource "aws_instance" "example" {
  # Use descriptive names
  name = "${var.environment}-${var.application}-web-server"

  # Always tag resources
  tags = {
    Environment = var.environment
    Application = var.application
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}
```

#### CloudFormation Best Practices

```yaml
# Template Organization
AWSTemplateFormatVersion: "2010-09-09"
Description: "Descriptive template description"

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]

Resources:
  # Use logical names
  WebServerInstance:
    Type: AWS::EC2::Instance
    Properties:
      Tags:
        - Key: Name
          Value: !Sub "${Environment}-WebServer"
```

### 3.3 Deployment Strategies

```yaml
Deployment Best Practices:
  Blue/Green Deployment:
    - Use for mission-critical applications
    - Implement with CodeDeploy or custom scripts
    - Validate thoroughly before switching traffic

  Rolling Deployment:
    - Use for applications that can handle mixed versions
    - Implement health checks at each stage
    - Plan rollback procedures

  Canary Deployment:
    - Start with small percentage of traffic
    - Monitor metrics closely
    - Automate rollback on failure
```

### 3.4 Change Management

```yaml
Change Management Process:
  - Use version control for all infrastructure code
  - Implement peer review for all changes
  - Use automated testing and validation
  - Document all changes and decisions
  - Implement change approval workflows
  - Plan and test rollback procedures
```

---

## 4. Reliability

### 4.1 Foundations

```yaml
Reliability Foundations:
  Service Quotas:
    - Monitor service limits and quotas
    - Request quota increases proactively
    - Implement quota monitoring alerts

  Network Topology:
    - Design for high availability across AZs
    - Use multiple regions for disaster recovery
    - Implement redundant connectivity paths
```

### 4.2 High Availability Architecture

```yaml
Multi-AZ Design:
  Compute:
    - Distribute instances across multiple AZs
    - Use Auto Scaling Groups for automatic recovery
    - Implement health checks and automated replacement

  Storage:
    - Use EBS with Multi-Attach where appropriate
    - Implement cross-AZ replication
    - Regular backup and restore testing

  Database:
    - Use RDS Multi-AZ for automatic failover
    - Implement read replicas for read scaling
    - Regular backup and point-in-time recovery testing
```

### 4.3 Disaster Recovery

```yaml
DR Strategy Levels:
  Backup and Restore (RTO: hours to days):
    - Regular automated backups
    - Cross-region backup replication
    - Documented restore procedures

  Pilot Light (RTO: 10s of minutes):
    - Core infrastructure always running
    - Data replication to DR region
    - Automated scaling procedures

  Warm Standby (RTO: minutes):
    - Scaled-down version always running
    - Automated scaling on failover
    - Regular failover testing

  Hot Standby/Multi-Site (RTO: seconds):
    - Full production environment in multiple regions
    - Active-active or active-passive configuration
    - Real-time data synchronization
```

### 4.4 Fault Tolerance Patterns

```yaml
Resilience Patterns:
  Circuit Breaker:
    - Implement timeouts and retries
    - Use exponential backoff
    - Monitor failure rates

  Bulkhead:
    - Isolate critical resources
    - Use separate capacity pools
    - Implement resource quotas

  Graceful Degradation:
    - Design for partial functionality
    - Implement fallback mechanisms
    - Prioritize critical features
```

---

## 5. Performance Efficiency

### 5.1 Compute Optimization

```yaml
Instance Selection:
  - Choose appropriate instance types for workload
  - Use latest generation instances
  - Consider graviton-based instances for cost savings
  - Implement right-sizing based on utilization

Auto Scaling:
  - Implement predictive scaling where possible
  - Use target tracking scaling policies
  - Set appropriate scaling thresholds
  - Monitor scaling metrics and adjust accordingly
```

### 5.2 Storage Optimization

```yaml
Storage Types:
  EBS:
    - Use gp3 for general purpose workloads
    - Use io2 for high IOPS requirements
    - Implement EBS optimization
    - Monitor burst credit balance

  S3:
    - Use appropriate storage classes
    - Implement lifecycle policies
    - Use S3 Transfer Acceleration for global uploads
    - Implement CloudFront for content delivery
```

### 5.3 Database Performance

```yaml
RDS Optimization:
  - Choose appropriate instance types
  - Implement read replicas for read scaling
  - Use connection pooling
  - Monitor key metrics (CPU, IOPS, connections)
  - Implement proper indexing strategies

DynamoDB Optimization:
  - Design efficient partition keys
  - Use GSIs appropriately
  - Implement auto-scaling
  - Monitor hot partitions
  - Use DAX for microsecond latency
```

### 5.4 Network Performance

```yaml
Network Optimization:
  - Use placement groups for high-performance computing
  - Implement enhanced networking (SR-IOV)
  - Use appropriate instance types for network performance
  - Consider AWS Global Accelerator for global applications
  - Implement CloudFront for content caching
```

---

## 6. Cost Optimization

### 6.1 Cost Management Framework

```yaml
Cost Management:
  Governance:
    - Implement cost allocation tags
    - Set up billing alerts and budgets
    - Regular cost reviews and optimization
    - Use AWS Cost Explorer for analysis

  Monitoring:
    - Track cost per service/application
    - Monitor resource utilization
    - Identify idle and underutilized resources
    - Implement cost anomaly detection
```

### 6.2 Resource Optimization

```yaml
Compute Optimization:
  Reserved Instances:
    - Analyze usage patterns
    - Purchase RIs for stable workloads
    - Use Convertible RIs for flexibility

  Spot Instances:
    - Use for fault-tolerant workloads
    - Implement spot fleet for diversification
    - Design applications to handle interruptions

  Savings Plans:
    - Use Compute Savings Plans for flexibility
    - Analyze commitment levels
    - Regular review and adjustment
```

### 6.3 Storage Cost Optimization

```yaml
S3 Cost Optimization:
  - Implement lifecycle policies
  - Use appropriate storage classes
  - Delete incomplete multipart uploads
  - Compress data where appropriate
  - Use S3 Intelligent-Tiering for changing access patterns

EBS Cost Optimization:
  - Delete unused volumes and snapshots
  - Use gp3 instead of gp2 for cost savings
  - Implement snapshot lifecycle management
  - Right-size volumes based on usage
```

---

## 7. Sustainability

### 7.1 Region and Resource Selection

```yaml
Sustainable Practices:
  Region Selection:
    - Choose regions with renewable energy
    - Consider data gravity and latency requirements
    - Use multiple regions for optimization

  Resource Efficiency:
    - Use Graviton processors where possible
    - Implement auto-scaling to match demand
    - Use serverless architectures where appropriate
    - Optimize resource utilization
```

### 7.2 Architecture Patterns

```yaml
Sustainable Architecture:
  - Use microservices for better resource utilization
  - Implement caching to reduce compute needs
  - Use CDNs to reduce data transfer
  - Design for efficiency over raw performance
  - Implement data compression and deduplication
```

---

## 8. Service-Specific Best Practices

### 8.1 Lambda Best Practices

```yaml
Function Design:
  - Keep functions small and focused
  - Minimize cold start impact
  - Use appropriate memory allocation
  - Implement proper error handling
  - Use layers for shared dependencies

Performance:
  - Initialize clients outside handler
  - Use connection pooling
  - Implement efficient algorithms
  - Monitor execution time and memory usage
  - Use provisioned concurrency for consistent performance

Security:
  - Use IAM roles for permissions
  - Store secrets in AWS Secrets Manager
  - Validate inputs
  - Implement least privilege access
```

### 8.2 API Gateway Best Practices

```yaml
API Design:
  - Use RESTful design principles
  - Implement proper HTTP status codes
  - Use request validation
  - Implement rate limiting
  - Use caching where appropriate

Security:
  - Use AWS WAF for protection
  - Implement authentication and authorization
  - Use API keys for rate limiting
  - Enable CloudTrail logging
  - Implement CORS properly
```

### 8.3 ECS/Fargate Best Practices

```yaml
Container Design:
  - Use multi-stage builds
  - Minimize image size
  - Use official base images
  - Implement health checks
  - Use init systems properly

Deployment:
  - Use rolling deployments
  - Implement blue/green deployments
  - Use service discovery
  - Implement auto-scaling
  - Monitor container metrics
```

### 8.4 EKS Best Practices

```yaml
Cluster Management:
  - Use managed node groups
  - Implement cluster autoscaling
  - Use multiple node groups for different workloads
  - Keep cluster and nodes updated
  - Implement network policies

Security:
  - Use RBAC for access control
  - Implement pod security policies
  - Use AWS Load Balancer Controller
  - Enable logging and monitoring
  - Use IAM roles for service accounts
```

---

## 9. Migration & Operations

### 9.1 Migration Strategies

```yaml
6 R's of Migration:
  Rehost (Lift and Shift):
    - Minimal changes to applications
    - Quick migration timeline
    - Use AWS Application Migration Service

  Replatform (Lift, Tinker, and Shift):
    - Minor cloud optimizations
    - Use managed services where possible
    - Maintain core architecture

  Refactor/Re-architect:
    - Significant application changes
    - Leverage cloud-native services
    - Improve performance and scalability

  Repurchase:
    - Move to SaaS solutions
    - Evaluate cost vs. functionality
    - Plan data migration

  Retain:
    - Keep applications on-premises
    - Maintain hybrid connectivity
    - Plan future migration

  Retire:
    - Decommission unused applications
    - Archive necessary data
    - Document decisions
```

### 9.2 Operations Automation

```yaml
Automation Framework:
  Infrastructure:
    - Use CloudFormation or Terraform
    - Implement GitOps workflows
    - Automate testing and validation
    - Use AWS Systems Manager for patching

  Application Deployment:
    - Use CodePipeline for CI/CD
    - Implement automated testing
    - Use blue/green deployments
    - Automate rollback procedures

  Operations:
    - Automate backup and restore
    - Implement auto-scaling
    - Use Lambda for operational tasks
    - Automate incident response
```

---

## 10. Monitoring & Observability

### 10.1 Monitoring Strategy

```yaml
Three Pillars of Observability:
  Metrics:
    - Use CloudWatch for AWS services
    - Implement custom metrics
    - Create dashboards for visibility
    - Set up alarms and notifications

  Logs:
    - Centralize logs in CloudWatch Logs
    - Implement structured logging
    - Use log aggregation and analysis
    - Implement log retention policies

  Traces:
    - Use AWS X-Ray for distributed tracing
    - Implement correlation IDs
    - Monitor request flows
    - Identify performance bottlenecks
```

### 10.2 Alerting Best Practices

```yaml
Alert Design:
  - Alert on symptoms, not causes
  - Implement alert fatigue prevention
  - Use appropriate alert channels
  - Implement escalation procedures
  - Regular review and tuning

Key Metrics to Monitor:
  - Application performance metrics
  - Infrastructure utilization
  - Security events
  - Business metrics
  - Cost and budget alerts
```

---

## 11. Automation & DevOps

### 11.1 CI/CD Pipeline Design

```yaml
Pipeline Stages:
  Source:
    - Use Git for version control
    - Implement branch protection
    - Use pull request workflows
    - Tag releases appropriately

  Build:
    - Automate dependency management
    - Run security scans
    - Execute unit tests
    - Generate artifacts

  Test:
    - Implement integration tests
    - Run security tests
    - Performance testing
    - Infrastructure validation

  Deploy:
    - Use blue/green or rolling deployments
    - Implement automated rollback
    - Monitor deployment health
    - Notify stakeholders
```

### 11.2 GitOps Implementation

```yaml
GitOps Principles:
  - Git as single source of truth
  - Declarative infrastructure
  - Automated deployment agents
  - Monitor and alert on drift
  - Implement proper access controls
```

---

## 12. Quick Reference Checklists

### 12.1 Security Checklist

```yaml
✅ Security Audit Checklist:
  IAM: □ Root user MFA enabled
    □ No unused IAM users
    □ Least privilege policies
    □ Regular access reviews
    □ No hardcoded credentials

  Network: □ VPC Flow Logs enabled
    □ Security groups follow least privilege
    □ No overly permissive rules (0.0.0.0/0)
    □ NACLs configured appropriately
    □ VPC endpoints for AWS services

  Data Protection: □ Encryption at rest enabled
    □ Encryption in transit enabled
    □ KMS key rotation enabled
    □ Backup encryption enabled
    □ S3 bucket policies secure

  Monitoring: □ CloudTrail enabled in all regions
    □ Config rules for compliance
    □ GuardDuty enabled
    □ Security Hub enabled
    □ CloudWatch alarms configured
```

### 12.2 Cost Optimization Checklist

```yaml
✅ Cost Review Checklist:
  Compute: □ Right-sized instances
    □ Spot instances where appropriate
    □ Reserved instances for stable workloads
    □ Auto-scaling configured
    □ Unused instances terminated

  Storage: □ S3 lifecycle policies implemented
    □ Unused EBS volumes deleted
    □ Snapshot lifecycle management
    □ Appropriate storage classes used
    □ Data compression implemented

  Network: □ Data transfer optimized
    □ CloudFront for content delivery
    □ VPC endpoints for AWS services
    □ Direct Connect for high volume
    □ NAT Gateway optimization

  Management: □ Cost allocation tags applied
    □ Budgets and alerts configured
    □ Regular cost reviews scheduled
    □ Unused resources identified
    □ Cost anomaly detection enabled
```

### 12.3 Performance Checklist

```yaml
✅ Performance Review Checklist:
  Application: □ Response time monitoring
    □ Throughput optimization
    □ Error rate tracking
    □ Resource utilization monitoring
    □ Bottleneck identification

  Infrastructure: □ Auto-scaling configured
    □ Load balancing implemented
    □ CDN for content delivery
    □ Database performance tuned
    □ Caching strategies implemented

  Network: □ Latency monitoring
    □ Bandwidth optimization
    □ Connection pooling
    □ DNS optimization
    □ Global load balancing
```

### 12.4 Operational Excellence Checklist

```yaml
✅ Operations Review Checklist:
  Automation: □ Infrastructure as Code implemented
    □ CI/CD pipelines automated
    □ Deployment automation
    □ Backup automation
    □ Monitoring automation

  Documentation: □ Architecture documented
    □ Runbooks created
    □ Incident response procedures
    □ Change management process
    □ Recovery procedures tested

  Monitoring: □ Comprehensive monitoring coverage
    □ Alerting strategy implemented
    □ Dashboard visibility
    □ Log aggregation configured
    □ Metric trending analyzed
```

---

## 13. Lambda Development Best Practices

### 13.1 Function Architecture Patterns

```yaml
Function Design Patterns:
  Single Purpose Functions:
    - One function per business capability
    - Avoid monolithic Lambda functions
    - Use Step Functions for orchestration
    - Implement proper error boundaries

  Handler Pattern:
    - Separate business logic from handler
    - Use dependency injection
    - Implement proper input validation
    - Return consistent response formats
```

#### Example: Clean Lambda Handler Structure

```python
import json
import os
from typing import Dict, Any
from infrastructure.helper.logger import Logger
from core.processors import ProcessorFactory

# Initialize outside handler for reuse
logger = Logger(service_name="central-to-dst-metadata")
processor_factory = ProcessorFactory()

def lambda_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """
    Clean Lambda handler with proper separation of concerns.
    """
    correlation_id = logger.get_correlation_id()

    try:
        # Input validation
        validated_event = validate_input(event)

        # Business logic delegation
        processor = processor_factory.create_processor(validated_event)
        result = processor.execute()

        logger.info("Processing completed successfully",
                   correlation_id=correlation_id,
                   result_summary=result)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "success": True,
                "data": result,
                "correlation_id": correlation_id
            })
        }

    except ValidationError as e:
        logger.error("Input validation failed", error=str(e))
        return error_response(400, "Validation Error", str(e))

    except Exception as e:
        logger.error("Unexpected error", error=str(e), correlation_id=correlation_id)
        return error_response(500, "Internal Error", "Processing failed")
```

### 13.2 Environment Configuration

```yaml
Configuration Management:
  Environment Variables:
    - Use for runtime configuration
    - Avoid hardcoded values
    - Implement validation at startup
    - Use Parameter Store for complex config

  Secrets Management:
    - Store sensitive data in AWS Secrets Manager
    - Use IAM roles for access control
    - Implement secret rotation
    - Cache secrets with TTL
```

#### Example: Configuration Handler

```python
import boto3
import os
from functools import lru_cache
from typing import Dict, Any

class ConfigManager:
    """Centralized configuration management for Lambda functions."""

    def __init__(self):
        self.ssm_client = boto3.client('ssm')
        self.secrets_client = boto3.client('secretsmanager')

    @lru_cache(maxsize=128)
    def get_parameter(self, parameter_name: str, decrypt: bool = True) -> str:
        """Get parameter from Systems Manager with caching."""
        try:
            response = self.ssm_client.get_parameter(
                Name=parameter_name,
                WithDecryption=decrypt
            )
            return response['Parameter']['Value']
        except Exception as e:
            raise ConfigurationError(f"Failed to get parameter {parameter_name}: {e}")

    @lru_cache(maxsize=32)
    def get_secret(self, secret_name: str) -> Dict[str, Any]:
        """Get secret from Secrets Manager with caching."""
        try:
            response = self.secrets_client.get_secret_value(SecretId=secret_name)
            return json.loads(response['SecretString'])
        except Exception as e:
            raise ConfigurationError(f"Failed to get secret {secret_name}: {e}")
```

### 13.3 Error Handling & Resilience

```yaml
Error Handling Patterns:
  Retry Logic:
    - Implement exponential backoff
    - Use circuit breaker pattern
    - Handle transient vs permanent errors
    - Log retry attempts

  Dead Letter Queues:
    - Configure DLQs for asynchronous invocations
    - Implement DLQ processing functions
    - Monitor DLQ metrics
    - Set appropriate retention periods
```

### 13.4 Performance Optimization

```yaml
Cold Start Optimization:
  - Initialize AWS clients outside handler
  - Use Lambda layers for shared dependencies
  - Minimize package size
  - Use provisioned concurrency for critical functions

Memory and Timeout Tuning:
  - Profile functions to determine optimal memory
  - Set appropriate timeout values
  - Monitor execution duration
  - Use X-Ray for performance tracing
```

---

## 14. Cross-Account Architecture Patterns

### 14.1 STS Assume Role Patterns

```yaml
Cross-Account Access Design:
  Hub and Spoke Model:
    - Central account for shared services
    - Spoke accounts for workloads
    - Centralized logging and monitoring
    - Shared IAM roles and policies

  Role Naming Conventions:
    - Use consistent naming patterns
    - Include purpose and environment
    - Document role purposes
    - Regular access reviews
```

#### Example: Cross-Account Role Implementation

```python
import boto3
from typing import Dict, Any, Optional
from botocore.exceptions import ClientError

class CrossAccountManager:
    """Manages cross-account access using STS assume role."""

    def __init__(self, region: str = 'us-east-1'):
        self.sts_client = boto3.client('sts', region_name=region)
        self.region = region

    def assume_role(
        self,
        account_id: str,
        role_name: str,
        session_name: str,
        duration_seconds: int = 3600
    ) -> boto3.Session:
        """
        Assume role in target account and return session.
        """
        role_arn = f"arn:aws:iam::{account_id}:role/{role_name}"

        try:
            response = self.sts_client.assume_role(
                RoleArn=role_arn,
                RoleSessionName=session_name,
                DurationSeconds=duration_seconds
            )

            credentials = response['Credentials']

            return boto3.Session(
                aws_access_key_id=credentials['AccessKeyId'],
                aws_secret_access_key=credentials['SecretAccessKey'],
                aws_session_token=credentials['SessionToken'],
                region_name=self.region
            )

        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'AccessDenied':
                raise CrossAccountError(f"Access denied for role {role_arn}")
            else:
                raise CrossAccountError(f"Failed to assume role: {e}")

    def get_caller_identity(self, session: boto3.Session) -> Dict[str, Any]:
        """Get identity information for assumed role session."""
        sts = session.client('sts')
        return sts.get_caller_identity()
```

### 14.2 Resource Sharing Patterns

```yaml
Cross-Account Resource Sharing:
  S3 Bucket Policies:
    - Grant cross-account access via bucket policies
    - Use condition keys for additional security
    - Implement least privilege access
    - Monitor cross-account access

  KMS Key Policies:
    - Allow cross-account key usage
    - Implement key administrators vs users
    - Use grants for temporary access
    - Monitor key usage across accounts
```

### 14.3 Monitoring and Auditing

```yaml
Cross-Account Monitoring:
  CloudTrail:
    - Enable in all accounts
    - Centralize logs in security account
    - Monitor cross-account API calls
    - Set up alerts for unusual activity

  Config Rules:
    - Deploy consistent rules across accounts
    - Monitor compliance centrally
    - Implement automated remediation
    - Regular compliance reporting
```

---

## 15. Infrastructure as Code (IaC) Development

### 15.1 Terraform Development Practices

```yaml
Terraform Best Practices:
  Project Structure:
    - Separate environments
    - Use modules for reusability
    - Implement consistent naming
    - Version control everything

  State Management:
    - Use remote state storage
    - Implement state locking
    - Separate state per environment
    - Regular state backups
```

#### Example: Terraform Module Structure

```hcl
# modules/lambda-function/main.tf
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_code_path" {
  description = "Path to source code"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

variable "layers" {
  description = "List of layer ARNs"
  type        = list(string)
  default     = []
}

# Create ZIP package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_code_path
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function resource
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role         = aws_iam_role.lambda_role.arn
  handler      = "lambda_function.lambda_handler"
  runtime      = "python3.11"
  timeout      = 300

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = var.layers

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
```

### 15.2 Version Control and GitOps

```yaml
GitOps Workflow:
  Branch Strategy:
    - Use feature branches for development
    - Implement pull request reviews
    - Protect main branches
    - Tag releases consistently

  CI/CD Integration:
    - Validate Terraform on PR
    - Plan on pull requests
    - Apply on merge to main
    - Implement approval gates
```

### 15.3 Testing Infrastructure Code

```yaml
Testing Strategies:
  Static Analysis:
    - Use tflint for Terraform linting
    - Implement security scanning
    - Validate syntax and formatting
    - Check for best practices

  Integration Testing:
    - Deploy to test environments
    - Validate resource creation
    - Test cross-resource dependencies
    - Cleanup after tests

  End-to-End Tests:
    - Test complete workflows
    - Validate business requirements
    - Test with realistic data volumes
    - Monitor performance metrics
```

---

## 16. Migration-Specific Patterns

### 16.1 Data Migration Strategies

```yaml
Data Migration Patterns:
  Batch Processing:
    - Use AWS Batch for large datasets
    - Implement checkpointing
    - Handle failures gracefully
    - Monitor progress and performance

  Streaming Migration:
    - Use Kinesis for real-time data
    - Implement CDC patterns
    - Handle ordering and deduplication
    - Monitor lag and throughput
```

### 16.2 Application Migration Patterns

```yaml
Migration Approaches:
  Strangler Fig Pattern:
    - Gradually replace legacy systems
    - Route traffic incrementally
    - Maintain data consistency
    - Monitor system health

  Database Migration:
    - Use AWS DMS for data replication
    - Implement schema migration tools
    - Plan for downtime windows
    - Validate data integrity
```

### 16.3 Migration Automation

```python
# Example: Migration orchestration with Step Functions
class MigrationOrchestrator:
    """Orchestrates complex migration workflows."""

    def __init__(self):
        self.stepfunctions = boto3.client('stepfunctions')
        self.dynamodb = boto3.resource('dynamodb')

    def start_migration(self, migration_config: Dict[str, Any]) -> str:
        """Start migration workflow."""

        state_machine_arn = migration_config['state_machine_arn']

        execution_input = {
            'migration_id': str(uuid.uuid4()),
            'source_config': migration_config['source'],
            'target_config': migration_config['target'],
            'migration_type': migration_config['type'],
            'batch_size': migration_config.get('batch_size', 1000)
        }

        response = self.stepfunctions.start_execution(
            stateMachineArn=state_machine_arn,
            input=json.dumps(execution_input)
        )

        return response['executionArn']
```

---

## 17. Data Processing & ETL Best Practices

### 17.1 Lambda ETL Patterns

```yaml
ETL Design Patterns:
  Event-Driven Processing:
    - Trigger on S3 events
    - Use SQS for buffering
    - Implement dead letter queues
    - Monitor processing metrics

  Batch Processing:
    - Use CloudWatch Events for scheduling
    - Implement checkpointing
    - Handle partial failures
    - Implement retry logic
```

### 17.2 Data Validation and Quality

```python
# Example: Data validation framework
from typing import List, Dict, Any
import pandas as pd

class DataValidator:
    """Validates data quality and structure."""

    def __init__(self, validation_rules: Dict[str, Any]):
        self.rules = validation_rules
        self.errors = []

    def validate_schema(self, data: pd.DataFrame) -> bool:
        """Validate data schema against expected structure."""
        required_columns = self.rules.get('required_columns', [])

        missing_columns = set(required_columns) - set(data.columns)
        if missing_columns:
            self.errors.append(f"Missing columns: {missing_columns}")
            return False

        return True

    def validate_data_quality(self, data: pd.DataFrame) -> bool:
        """Validate data quality rules."""
        quality_checks = self.rules.get('quality_checks', {})

        # Check for null values
        if 'null_check' in quality_checks:
            null_columns = quality_checks['null_check']
            for column in null_columns:
                if data[column].isnull().any():
                    self.errors.append(f"Null values found in {column}")

        # Check data types
        if 'type_check' in quality_checks:
            type_checks = quality_checks['type_check']
            for column, expected_type in type_checks.items():
                if not data[column].dtype == expected_type:
                    self.errors.append(f"Invalid type for {column}")

        return len(self.errors) == 0
```

---

## 18. Event-Driven Architecture

### 18.1 Event Design Patterns

```yaml
Event Architecture:
  Event Sourcing:
    - Store events instead of current state
    - Use DynamoDB for event store
    - Implement event replay capability
    - Handle event versioning

  CQRS (Command Query Responsibility Segregation):
    - Separate read and write models
    - Use different data stores for reads/writes
    - Implement eventual consistency
    - Optimize for different access patterns
```

### 18.2 Event Processing Patterns

```python
# Example: Event processor with retry logic
class EventProcessor:
    """Processes events with built-in retry logic."""

    def __init__(self, max_retries: int = 3):
        self.max_retries = max_retries
        self.logger = Logger()

    def process_event(self, event: Dict[str, Any]) -> bool:
        """Process individual event with retry logic."""

        for attempt in range(self.max_retries + 1):
            try:
                # Extract event details
                event_type = event.get('eventName')
                event_source = event.get('eventSource')

                # Route to appropriate handler
                handler = self.get_handler(event_type)
                result = handler.handle(event)

                self.logger.info(
                    "Event processed successfully",
                    event_type=event_type,
                    attempt=attempt + 1
                )

                return True

            except RetryableError as e:
                if attempt < self.max_retries:
                    wait_time = 2 ** attempt  # Exponential backoff
                    self.logger.warning(
                        f"Retrying event processing in {wait_time}s",
                        error=str(e),
                        attempt=attempt + 1
                    )
                    time.sleep(wait_time)
                else:
                    self.logger.error(
                        "Max retries exceeded for event",
                        event_type=event_type,
                        error=str(e)
                    )
                    return False

            except PermanentError as e:
                self.logger.error(
                    "Permanent error processing event",
                    event_type=event_type,
                    error=str(e)
                )
                return False

        return False
```

---

## 19. Code Quality & Testing

### 19.1 Testing Strategies for IaC

```yaml
Testing Pyramid for IaC:
  Unit Tests:
    - Test individual modules
    - Mock external dependencies
    - Validate resource configurations
    - Test input validation

  Integration Tests:
    - Test module interactions
    - Validate cross-resource dependencies
    - Test actual AWS resource creation
    - Cleanup resources after tests

  End-to-End Tests:
    - Test complete workflows
    - Validate business requirements
    - Test with realistic data volumes
    - Monitor performance metrics
```

### 19.2 Python Testing Best Practices

```python
# Example: Comprehensive test structure
import pytest
import boto3
from moto import mock_s3, mock_dynamodb, mock_sts
from unittest.mock import patch, MagicMock

class TestCentralToDstMetadata:
    """Test suite for central-to-dst-metadata processor."""

    @pytest.fixture
    def mock_aws_services(self):
        """Set up mock AWS services for testing."""
        with mock_s3(), mock_dynamodb(), mock_sts():
            # Create mock S3 bucket
            s3 = boto3.client('s3', region_name='us-east-1')
            s3.create_bucket(Bucket='test-bucket')

            # Create mock DynamoDB table
            dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
            table = dynamodb.create_table(
                TableName='test-mapping-table',
                KeySchema=[
                    {'AttributeName': 'project_id', 'KeyType': 'HASH'}
                ],
                AttributeDefinitions=[
                    {'AttributeName': 'project_id', 'AttributeType': 'S'}
                ],
                BillingMode='PAY_PER_REQUEST'
            )

            yield {
                's3': s3,
                'dynamodb': dynamodb,
                'table': table
            }

    def test_processor_initialization(self):
        """Test processor initializes correctly."""
        processor = CentralToDstMetadata(
            enable_cross_account=True,
            xls_source_bucket='test-bucket',
            xls_source_key='test.xlsx',
            default_cross_account_role='test-role',
            region='us-east-1',
            lambda_event={'test': 'event'}
        )

        assert processor.enable_cross_account == True
        assert processor.correlation_id is not None

    @patch('central_to_dst_metadata.pd.read_excel')
    def test_xls_configuration_reading(self, mock_read_excel, mock_aws_services):
        """Test XLS configuration reading with mocked data."""
        # Mock pandas DataFrame
        mock_df = MagicMock()
        mock_df.to_dict.return_value = [
            {'AccountId': '123456789012', 'ProjectId': 'test-project'}
        ]
        mock_read_excel.return_value = mock_df

        processor = CentralToDstMetadata(
            enable_cross_account=True,
            xls_source_bucket='test-bucket',
            xls_source_key='test.xlsx',
            default_cross_account_role='test-role',
            region='us-east-1',
            lambda_event={'test': 'event'}
        )

        # Upload test file to mock S3
        s3 = mock_aws_services['s3']
        s3.put_object(
            Bucket='test-bucket',
            Key='test.xlsx',
            Body=b'test data'
        )

        configs = processor._read_xls_configuration()

        assert len(configs) == 1
        assert configs[0]['AccountId'] == '123456789012'
```

### 19.3 Performance Testing

```python
# Example: Performance testing framework
import time
import statistics
from typing import List, Dict, Any

class PerformanceTester:
    """Framework for performance testing Lambda functions."""

    def __init__(self, function_name: str):
        self.function_name = function_name
        self.lambda_client = boto3.client('lambda')
        self.results = []

    def run_performance_test(
        self,
        test_events: List[Dict[str, Any]],
        iterations: int = 10
    ) -> Dict[str, Any]:
        """Run performance test with multiple iterations."""

        execution_times = []

        for i in range(iterations):
            for event in test_events:
                start_time = time.time()

                response = self.lambda_client.invoke(
                    FunctionName=self.function_name,
                    Payload=json.dumps(event)
                )

                end_time = time.time()
                execution_time = (end_time - start_time) * 1000  # Convert to ms
                execution_times.append(execution_time)

        return {
            'mean_execution_time': statistics.mean(execution_times),
            'median_execution_time': statistics.median(execution_times),
            'max_execution_time': max(execution_times),
            'min_execution_time': min(execution_times),
            'total_executions': len(execution_times)
        }
```

---

## 20. Deployment Pipelines for IaC

### 20.1 GitOps Workflow Implementation

```yaml
GitOps Pipeline Stages:
  1. Source Control:
    - Feature branch creation
    - Pull request with code review
    - Automated validation on PR
    - Merge to main branch

  2. Build & Validate:
    - Terraform fmt and validate
    - Security scanning (tfsec)
    - Unit tests execution
    - Documentation generation

  3. Plan & Review:
    - Terraform plan generation
    - Plan review and approval
    - Environment-specific validation
    - Cost estimation

  4. Deploy:
    - Terraform apply execution
    - Post-deployment validation
    - Monitoring setup
    - Rollback procedures
```

### 20.2 Multi-Environment Deployment

```hcl
# Example: Environment-specific deployment configuration
# .github/workflows/terraform-deploy.yml
name: Terraform Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
        aws-region: us-east-1

    - name: Terraform Init
      run: |
        cd environments/${{ matrix.environment }}
        terraform init

    - name: Terraform Plan
      run: |
        cd environments/${{ matrix.environment }}
        terraform plan -var-file="${{ matrix.environment }}.tfvars"

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: |
        cd environments/${{ matrix.environment }}
        terraform apply -auto-approve -var-file="${{ matrix.environment }}.tfvars"
```

### 20.3 Deployment Validation

```python
# Example: Post-deployment validation
class DeploymentValidator:
    """Validates deployment success and health."""

    def __init__(self, region: str):
        self.region = region
        self.lambda_client = boto3.client('lambda', region_name=region)
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)

    def validate_lambda_deployment(self, function_name: str) -> bool:
        """Validate Lambda function deployment."""
        try:
            # Check function exists and is active
            response = self.lambda_client.get_function(FunctionName=function_name)
            state = response['Configuration']['State']

            if state != 'Active':
                raise ValidationError(f"Function {function_name} is not active: {state}")

            # Test function invocation
            test_event = {'test': True}
            invoke_response = self.lambda_client.invoke(
                FunctionName=function_name,
                Payload=json.dumps(test_event)
            )

            if invoke_response['StatusCode'] != 200:
                raise ValidationError(f"Function invocation failed: {invoke_response}")

            return True

        except Exception as e:
            raise ValidationError(f"Lambda validation failed: {e}")

    def validate_monitoring(self, function_name: str) -> bool:
        """Validate monitoring and alerting setup."""
        try:
            # Check CloudWatch alarms exist
            response = self.cloudwatch.describe_alarms(
                AlarmNamePrefix=function_name
            )

            alarms = response['MetricAlarms']
            if not alarms:
                raise ValidationError(f"No alarms found for {function_name}")

            # Validate alarm states
            for alarm in alarms:
                if alarm['StateValue'] == 'INSUFFICIENT_DATA':
                    # This is expected for new deployments
                    continue
                elif alarm['StateValue'] == 'ALARM':
                    raise ValidationError(f"Alarm {alarm['AlarmName']} is in ALARM state")

            return True

        except Exception as e:
            raise ValidationError(f"Monitoring validation failed: {e}")
```

### 20.4 Rollback Strategies

```yaml
Rollback Procedures:
  Automated Rollback:
    - Monitor deployment health metrics
    - Define rollback triggers (error rates, latency)
    - Implement automatic rollback on failures
    - Notify teams of rollback events

  Manual Rollback:
    - Document rollback procedures
    - Test rollback in staging environment
    - Implement rollback approval process
    - Validate post-rollback health
```

---

## 21. Migration Project Patterns

### 21.1 Infrastructure Migration Workflow

```yaml
Migration Phases:
  1. Discovery & Assessment:
    - Inventory existing infrastructure
    - Identify dependencies
    - Assess migration complexity
    - Create migration plan

  2. Design & Architecture:
    - Design target AWS architecture
    - Plan security and compliance
    - Design migration tools
    - Create testing strategy

  3. Implementation:
    - Build migration tools
    - Implement infrastructure code
    - Test migration procedures
    - Train operations team

  4. Migration Execution:
    - Execute pilot migrations
    - Perform production migration
    - Monitor and validate
    - Optimize and tune
```

### 21.2 Data Migration Patterns

```python
# Example: Comprehensive data migration framework
class DataMigrationManager:
    """Manages complex data migration workflows."""

    def __init__(self, migration_config: Dict[str, Any]):
        self.config = migration_config
        self.logger = Logger(service_name="data-migration")
        self.metrics = {}

    def execute_migration(self) -> Dict[str, Any]:
        """Execute complete data migration workflow."""
        migration_id = str(uuid.uuid4())

        try:
            # Phase 1: Pre-migration validation
            self.validate_source_data()
            self.validate_target_environment()

            # Phase 2: Data extraction and transformation
            extracted_data = self.extract_data()
            transformed_data = self.transform_data(extracted_data)

            # Phase 3: Data loading with validation
            load_result = self.load_data(transformed_data)

            # Phase 4: Post-migration validation
            validation_result = self.validate_migration()

            return {
                'migration_id': migration_id,
                'status': 'success',
                'metrics': self.metrics,
                'validation': validation_result
            }

        except Exception as e:
            self.logger.error(
                "Migration failed",
                migration_id=migration_id,
                error=str(e)
            )

            # Attempt rollback
            self.rollback_migration()

            return {
                'migration_id': migration_id,
                'status': 'failed',
                'error': str(e)
            }
```

---

_These additional sections provide specific guidance for coding and deployment practices aligned with your IaC Polyglot project, covering Lambda development, cross-account patterns, infrastructure automation, migration workflows, and comprehensive testing strategies._
