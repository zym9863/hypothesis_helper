# hypothesis_helper

[English Version](README_EN.md) | [中文版](README.md)
# hypothesis_helper

# Hypothesis Helper

A fully featured Flutter application designed for statistical hypothesis testing, offering both a calculator and interactive learning modules.

## 🌟 Main Features

### 📊 Parametric and Nonparametric Test Calculator
- **Parametric Tests**: One-sample/two-sample t-test, paired t-test, one-sample/two-sample Z-test, ANOVA
- **Nonparametric Tests**: Sign test, Wilcoxon signed-rank test
- **Other Tests**: Chi-square goodness-of-fit test
- **Smart Data Validation**: Automatically detects data quality issues and outliers
- **Sample Data**: One-click load of sample data for quick testing

### 🎓 Interactive Learning Module
- **P-value Visualization**: Dynamically shows the relationship between p-value and test statistic
- **Error Types Learning**: Interactive explanation of Type I and Type II errors
- **Probability Distribution Charts**: Visualization of normal, t, chi-square, and F distributions
- **Effect Size Analysis**: Calculation and explanation of effect size metrics such as Cohen's d

### 📈 Advanced Visualization
- **Distribution Charts**: Display test statistics, rejection regions, and p-value areas
- **Statistical Summary**: Visual presentation of key statistics
- **Effect Size Charts**: Intuitive representation and explanation of effect size

## 🚀 Technical Features

- **Flutter Framework**: Cross-platform support (iOS, Android, Web, Desktop)
- **Provider State Management**: Efficient state management and data flow
- **FL Chart Library**: Professional statistical chart visualization
- **Responsive Design**: Adapts to different screen sizes
- **Performance Optimization**: Result caching and calculation optimization
- **Data Validation**: Comprehensive input validation and error handling

## 📱 Interface Screenshots

### Main Interface
- Calculator module entry
- Learning module entry
- Clear function categorization

### Calculator Interface
- Test type selection
- Data input and validation
- Parameter settings
- Result display and visualization

### Learning Module
- P-value visualization tool
- Error type interactive learning
- Probability distribution dynamic display

## 🛠️ Installation and Running

### Requirements
- Flutter SDK 3.8.1+
- Dart 3.0+

### Installation Steps
1. Clone the project
```bash
git clone https://github.com/zym9863/hypothesis_helper.git
cd hypothesis_helper
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📚 User Guide

### Performing Hypothesis Tests
1. Select the "Calculator" module
2. Click "Start Calculation"
3. Choose the appropriate test type
4. Enter sample data (sample data available)
5. Set significance level and other parameters
6. View calculation results and visualization charts

### Learning Statistical Concepts
1. Select the "Learning Module"
2. Choose a topic of interest
3. Explore concepts through interactive components
4. Adjust parameters to observe changes

## 🧮 Supported Test Types

### Parametric Tests
- **One-sample t-test**: Test whether the sample mean equals a known population mean
- **Two-sample t-test**: Compare the mean difference between two independent samples
- **Paired t-test**: Compare the mean difference of paired samples
- **One-sample Z-test**: Mean test when population variance is known
- **Two-sample Z-test**: Two-sample mean test when population variance is known
- **ANOVA**: Compare mean differences among multiple groups

### Nonparametric Tests
- **Sign test**: Test whether the sample median equals a known value
- **Wilcoxon signed-rank test**: Nonparametric one-sample location test

### Other Tests
- **Chi-square goodness-of-fit test**: Test the difference between observed and expected frequencies

## 🎯 Learning Features

### P-value Visualization
- Real-time adjustment of test statistics
- Observe changes in p-value regions
- Understand the relationship between p-value and significance level

### Error Types Learning
- Type I error (α error)
- Type II error (β error)
- Test power (1-β)
- Effect of parameters on error probabilities

### Probability Distributions
- Normal distribution
- t distribution
- Chi-square distribution
- F distribution
- Parameter adjustment and distribution changes

## 🔧 Technical Architecture

### Core Modules
- **models/**: Data model definitions
- **services/**: Statistical calculation services
- **providers/**: State management
- **screens/**: UI components
- **widgets/**: Reusable components
- **utils/**: Utility classes

### Main Dependencies
- `flutter`: Core framework
- `provider`: State management
- `fl_chart`: Chart visualization
- `math_expressions`: Math expression parsing

## 🧪 Testing

Run tests:
```bash
flutter test
```

Included tests:
- Unit tests: Statistical calculation validation
- Widget tests: UI component functionality
- Integration tests: Full process validation

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

For questions or suggestions, please contact:
- Create an Issue
- Send an email

## 🙏 Acknowledgements

Thanks to all developers and researchers who contribute to statistics education and open-source software.
