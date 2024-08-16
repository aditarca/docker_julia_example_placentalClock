using CSV
using DataFrames
using GLM
using CodecZlib

# Make sure the training data files provided are in the current directory

# Read annotation data for all training samples
meta = CSV.read("Sample_annotation.csv", DataFrame);
meta.rowname = meta.Sample_ID;

# Read feature data from a compressed CSV file for the first 100 features only and all samples (for speed reasons)
# Remove limit argument to read all features
# Samples are columns and rows are features
gz_stream = GzipDecompressorStream(open("Beta_raw_subchallenge1.csv.gz", "r"));
X = CSV.read(gz_stream, DataFrame; limit=100);

# Transpose the feature data
X_df= permutedims(X,1,"Sample_ID");

# Extract the target gestational age and perform an inner join based on the "Sample_ID" column 
joined_df = innerjoin(X_df, meta[:,[:Sample_ID,:GA]], on = :Sample_ID);
df = select!(joined_df,Not(:Sample_ID));


# predictor_columns = filter(c -> c != "GA", names(df))
# formula_str = "GA ~ " * join(string.(predictor_columns), " + ")
# formula = Meta.parse(formula_str)
# Fit a simple linear model that predicts GA using 6 random features. Create your own model here instead
model = lm(@formula(GA ~ cg18478105 + cg09835024 + cg14361672 + cg01763666 + cg12950382 + cg02115394), df);


# Save the model needed for docker submission
using Serialization
serialize("model_test_SC1.jls", model)


