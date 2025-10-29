# Use official Python image
FROM python:3.10-slim

# Set work directory
WORKDIR /app

# Copy everything
COPY . .

# Install dependencies
RUN pip install --no-cache-dir flask tensorflow keras numpy pandas opencv-python

# Expose the API port
EXPOSE 5001

# Run the Flask app
CMD ["python", "app.py"]
