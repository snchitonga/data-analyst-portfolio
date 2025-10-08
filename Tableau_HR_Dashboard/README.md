HR Analytics Dashboard – Tableau Project

## 🎯 Project Overview
This project simulates a real-world **HR analytics dashboard** designed for managers to analyze key workforce insights — from employee demographics to income patterns and performance metrics.

The dataset was **generated using Python (Faker library)** and visualized using **Tableau** to create both a **summary view** and a **detailed employee records view**.

---

## 📊 Dashboard Sections

### 1️⃣ Overview
- Total hired, active, and terminated employees.
- Hires and terminations over time.
- Employee distribution by department and job title.
- Comparison between **Headquarters (New York)** and other branches.
- Employee locations by **city** and **state**.

### 2️⃣ Demographics
- Gender ratio and representation across departments.
- Employee distribution by **age** and **education level**.
- Relationship between **education** and **performance rating**.

### 3️⃣ Income Analysis
- Salary comparisons across genders and education levels.
- Salary vs. age across departments.
- Identified pay gap patterns and salary trends.

### 4️⃣ Employee Records
- Full list of all employees with filters for:
  - Department
  - Gender
  - Education
  - Job Title
  - Performance

---

## 🧠 Tools & Technologies
- **Python** – Data generation using Faker & NumPy  
- **Pandas** – Data cleaning and manipulation  
- **Tableau** – Visualization and dashboard creation  

---

## 🧩 Dataset
- **Records:** 8,950 synthetic employees  
- **Attributes:** Employee ID, Name, Gender, State, City, Department, Job Title, Education, Salary, Performance, Overtime, Hire/Termination/Birth Dates  
- **Data Source:** Generated via ChatGPT + Python script  

---

## 🚀 Key Insights
- Over **60% of employees** work in Operations and Sales.  
- Women with higher education levels show slightly higher salary growth rates.  
- HQ (New York) maintains the largest workforce share.  
- Salary distribution increases consistently with both **education level** and **age**.

---

## 💾 Files
- `hr_data_generator.py` → Python code to generate dataset  
- `HumanResources.csv` → Generated dataset  
- `HR_Insights_Dashboard.twbx` → Tableau packaged workbook  

---

## 🏁 How to Open
1. Open `HR_Insights_Dashboard.twbx` in **Tableau Desktop or Tableau Public**.
2. Use filters to explore demographic, income, and performance insights.
3. Review the Python file to see the **data generation logic**.

---

✨ *This project demonstrates end-to-end HR data analysis - from data creation and preparation in Python to interactive dashboarding in Tableau.*
