using CSV
using DataFrames
using GLM
using ArgParse
using Serialization


# Set up argument parsing
function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--input"
        help = "Input directory"
        default = "/input"
        
        "--output"
        help = "Output directory"
        default = "/output"
    end
    return parse_args(s)
end

# Parse command-line arguments
args = parse_commandline()


# Load the pre-trained model
model = deserialize("/usr/local/bin/model_test_SC1.jls")

# Make predictions on new data
new_df = CSV.read(joinpath(args["input"], "Leaderboard_beta_subchallenge1.csv"), DataFrame)
new_df = permutedims(new_df, 1, "Sample_ID")
ID = new_df[:, "Sample_ID"]
new_df = new_df[:, ["cg18478105", "cg09835024", "cg14361672", "cg01763666", "cg12950382", "cg02115394"]]

# Predict gestational age
predictions = predict(model, new_df)

# Ensure predictions are within a valid range
predictions[predictions .> 44] .= 44
predictions[predictions .< 5] .= 5

# Combine predictions with IDs
output_df = DataFrame(ID=ID, GA_prediction=predictions)

# Write the predictions to the output directory
CSV.write(joinpath(args["output"], "predictions.csv"), output_df)

