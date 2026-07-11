resource "aws_vpc" "kvs_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, { Name = var.vpc_name })
}

# ─── Internet Gateway ──────────────────────────────────────────────────────────
resource "aws_internet_gateway" "kvs_igw" {
  vpc_id = aws_vpc.kvs_vpc.id

  tags = merge(var.tags, { Name = "${var.vpc_name}-igw" })
}

# ─── Subnets ───────────────────────────────────────────────────────────────────
resource "aws_subnet" "kvs_public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.kvs_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-${var.availability_zones[count.index]}"
    Tier = "public"
  })
}

resource "aws_subnet" "kvs_private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.kvs_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-${var.availability_zones[count.index]}"
    Tier = "private"
  })
}

# ─── NAT Gateway ──────────────────────────────────────────────────────────────
resource "aws_eip" "kvs_nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.vpc_name}-nat-eip" })

  depends_on = [aws_internet_gateway.kvs_igw]
}

resource "aws_nat_gateway" "kvs_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.kvs_nat[0].id
  subnet_id     = aws_subnet.kvs_public[0].id

  tags = merge(var.tags, { Name = "${var.vpc_name}-nat" })

  depends_on = [aws_internet_gateway.kvs_igw]
}

# ─── Route Tables ─────────────────────────────────────────────────────────────
resource "aws_route_table" "kvs_public_rt" {
  vpc_id = aws_vpc.kvs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kvs_igw.id
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route_table" "kvs_private_rt" {
  vpc_id = aws_vpc.kvs_vpc.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.kvs_nat[0].id
    }
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-private-rt" })
}

# ─── Route Table Associations ─────────────────────────────────────────────────
resource "aws_route_table_association" "kvs_public" {
  count = length(aws_subnet.kvs_public)

  subnet_id      = aws_subnet.kvs_public[count.index].id
  route_table_id = aws_route_table.kvs_public_rt.id
}

resource "aws_route_table_association" "kvs_private" {
  count = length(aws_subnet.kvs_private)

  subnet_id      = aws_subnet.kvs_private[count.index].id
  route_table_id = aws_route_table.kvs_private_rt.id
}
