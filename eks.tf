//EKS CLUSTER
resource "aws_eks_cluster" "main" {
  name     = "cluster"
  role_arn = aws_iam_role.iam_clusterrole.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = flatten([aws_subnet.publicsubnets[*].id, aws_subnet.privatesubnets[*].id, ])
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = merge(var.comman_tags, {
    "Name" = "${var.project_name}-${var.environment_name}-cluster"
  })

  depends_on = [aws_iam_role_policy_attachment.clusterrolepolicyattachment]

}

// EKS Cluster IAM Role 
resource "aws_iam_role" "iam_clusterrole" {
  name               = "iam_clusterrole"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json #we just mention which service
  tags = merge(var.comman_tags,
    {
      "Name" = "${var.project_name}-${var.environment_name}-cluster"
  })
}

//EKS CLUSTER POLICY ATTACHMENT
resource "aws_iam_role_policy_attachment" "clusterrolepolicyattachment" {
  role       = aws_iam_role.iam_clusterrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

//EKS Worker Node Group
resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "Cluster-nodegroup"

  subnet_ids    = aws_subnet.privatesubnets[*].id
  node_role_arn = aws_iam_role.worker_iam_role.arn # we attached the iam role


  scaling_config {
    desired_size = var.nodegroup_desired_size
    min_size     = var.nodegroup_min_size
    max_size     = var.nodegroup_max_size

  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = [var.nodegroup_instance_type]
  disk_size      = 20
  capacity_type  = "ON_DEMAND"

  depends_on = [aws_iam_role_policy_attachment.workernodepolicyattachment]

  tags = merge(var.comman_tags,
    {
      "Name" = "${var.project_name}-${var.environment_name}-cluster-nodegroup"
  })

}

//IAM ROLE FOR WORKER NODE

resource "aws_iam_role" "worker_iam_role" {
  name = "cluster-iam-worker-role"

  assume_role_policy = data.aws_iam_policy_document.worker_assume_role.json
}

resource "aws_iam_role_policy_attachment" "workernodepolicyattachment" {

  for_each   = var.eks_worker_nodegroup_policy
  role       = aws_iam_role.worker_iam_role.name
  policy_arn = each.value

}