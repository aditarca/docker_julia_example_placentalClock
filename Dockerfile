# Use Ubuntu Focal as the base image
FROM ubuntu:20.04

# Install  necessary dependencies & Julia 
RUN apt-get update && apt-get install -y gnupg lsb-release software-properties-common 
RUN apt-get install -y wget 
    

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.3-linux-x86_64.tar.gz
RUN tar -xvzf julia-1.5.3-linux-x86_64.tar.gz -C /opt/  
RUN rm julia-1.5.3-linux-x86_64.tar.gz
RUN ln -s /opt/julia-1.5.3/bin/julia /usr/local/bin/julia 

# Copy your script and model file into the container
COPY run_model.jl /usr/local/bin
COPY model_test_SC1.jls /usr/local/bin

# Install required Julia packages
RUN julia -e 'using Pkg; Pkg.add(["CSV", "DataFrames", "GLM", "CodecZlib", "ArgParse", "Serialization"]); Pkg.precompile()'

# Define the entrypoint command
ENTRYPOINT ["julia", "/usr/local/bin/run_model.jl"]
