Python Movie Correlation Project
Overview

This project analyzes 6820 movies from 1986–2016 to explore correlations between movie attributes such as budget, gross revenue, runtime, IMDb score, and votes. The goal is to understand trends in the movie industry and factors that influence revenue and ratings.

Dataset

Source: Kaggle / IMDb

Location: data/movies.csv

Contents:

budget – movie budget (some missing values)

gross – revenue

company – production company

country – country of origin

director – director

genre – main genre

name – movie title

rating – movie rating (R, PG, etc.)

released – release date (YYYY-MM-DD)

runtime – duration in minutes

score – IMDb rating

votes – number of votes

star – main actor/actress

writer – writer

year – release year



Steps Performed

Data Cleaning – handled missing values, formatted dates, and replaced zeros in budget/gross.

Exploratory Data Analysis (EDA) – explored distributions, outliers, and trends.

Correlation Analysis – computed correlations between numeric attributes.

Visualizations – scatter plots, heatmaps, and trend charts.

Insights – interpreted correlations and trends in the movie industry.

How to Run

Clone the repo.

Install dependencies:

pip install pandas numpy matplotlib seaborn


Open the notebook:

jupyter notebook notebooks/movie_correlation_analysis.ipynb


Run all cells to reproduce analysis and visualizations.

Key Insights

Budget is moderately correlated with gross revenue.

IMDb score shows weak correlation with gross revenue.

Runtime has almost no correlation with revenue or score.

Certain genres consistently perform better at the box office.