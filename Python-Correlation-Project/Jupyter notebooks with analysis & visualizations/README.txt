🎬 Python Movie Correlation Project
Overview

This project analyzes 6,820 movies from 1986–2016 to explore correlations between movie attributes such as budget, gross revenue, runtime, IMDb score, and votes.
The goal is to uncover trends in the movie industry and identify factors that influence revenue and ratings.

Dataset

Source: Kaggle / IMDb

Location in repo: data/movies.csv

Columns include:

Column	Description
budget	Movie budget (some missing values)
gross	Revenue generated
company	Production company
country	Country of origin
director	Movie director
genre	Main genre
name	Movie title
rating	Movie rating (R, PG, etc.)
released	Release date (YYYY-MM-DD)
runtime	Duration in minutes
score	IMDb rating
votes	Number of votes
star	Main actor/actress
writer	Writer
year	Release year
Steps Performed

Data Cleaning – Handled missing values, formatted dates, and replaced zeros in budget and gross.

Exploratory Data Analysis (EDA) – Explored distributions, outliers, and trends in the dataset.

Correlation Analysis – Computed correlations between numeric attributes to understand relationships.

Visualizations – Created scatter plots, heatmaps, and trend charts to illustrate findings.

Insights – Interpreted correlations and industry trends based on analysis.

How to Run

Clone the repository:

git clone <your-repo-url>


Install dependencies:

pip install pandas numpy matplotlib seaborn jupyter


Open the notebook:

jupyter notebook notebooks/movie_correlation_analysis.ipynb


Run all cells to reproduce the analysis and visualizations.

Key Insights

Budget is moderately correlated with gross revenue.

IMDb score shows weak correlation with gross revenue.

Runtime has almost no correlation with revenue or score.

Certain genres consistently perform better at the box office.