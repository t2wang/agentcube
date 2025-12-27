# Build stage
FROM golang:1.24.4 AS builder

# Build arguments for multi-architecture support
ARG TARGETOS=linux
ARG TARGETARCH

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -a -installsuffix cgo -o picod ./cmd/picod

# Run stage
FROM ubuntu:24.04

# Install Python3 and necessary system libraries to support code execution tasks
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    poppler-utils \
    wkhtmltopdf \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install requested Python packages
RUN pip install --no-cache-dir --break-system-packages \
    pandas \
    numpy \
    matplotlib \
    matplotlib-inline \
    matplotlib-venn \
    plotly \
    openpyxl \
    xlrd \
    XlsxWriter \
    pyxlsb \
    et-xmlfile \
    PyPDF2 \
    pdfplumber \
    pdf2image \
    pdfkit \
    pypdfium2 \
    pdfminer.six \
    pdfrw \
    python-docx \
    docx2txt \
    reportlab \
    fpdf \
    rarfile \
    pillow \
    opencv-python-headless \
    imageio \
    pypng

# Use /root/ as the working directory
# We run as root to allow 'chattr +i' on the public key file (see pkg/picod/auth.go)
# and to ensure sufficient permissions for arbitrary code execution within the sandbox.
WORKDIR /root/

COPY --from=builder /app/picod .

ENTRYPOINT ["./picod"]
