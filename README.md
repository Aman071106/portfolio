# Portfolio Website

This is the source code for my personal portfolio website. The website showcases my skills, experience, projects, and blog posts. It is built using **Flutter** for a smooth and responsive experience, with data fetched from **Firebase**.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Technologies Used](#technologies-used)
3. [Setup and Installation](#setup-and-installation)
4. [Deploying the Website](#deploying-the-website)
5. [Features](#features)

---

## Technologies Used

- **Flutter**: A UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.
- **Firebase**: For real-time data fetching and storing blog posts, projects, and more.
- **Dart**: Programming language used for building the app.
- **JSON**: Local data files (e.g., skills, experience) in JSON format.

---

## Setup and Installation

Follow the steps below to set up the project locally:

1. Clone the repository:
    ```bash
    git clone https://github.com/Aman071106/portfolio.git
    ```

2. Navigate to the project directory:
    ```bash
    cd portfolio_website
    ```

3. Install dependencies:
    ```bash
    flutter pub get
    ```

4. If you're using Firebase for data, ensure your Firebase project is set up and configured in the Firebase console, then link your project by initializing Firebase in your app.

---

## Deploying the Website

To deploy your portfolio website to Firebase Hosting, follow these steps:

1. **Build the web app**:
    ```bash
    flutter build web
    ```

2. **Initialize Firebase Hosting**:
    ```bash
    firebase init hosting
    ```
    - Choose your Firebase project.
    - Set the public directory to `build/web`.
    - Configure as a single-page app (Yes).

3. **Deploy to Firebase**:
    ```bash
    firebase deploy
    ```

---

### Automatic Deployment via GitHub (Optional)

You can also set up **automatic deployment** to Firebase directly from GitHub. Follow the instructions during `firebase init hosting` to connect your repository. Every time you push changes to your GitHub repository, Firebase will automatically rebuild and redeploy your site.

---

### Manual Deployment (When Making Changes)

For future changes:

1. **Build the web app** after making changes:
    ```bash
    flutter build web
    ```

2. **Deploy** the updated app:
    ```bash
    firebase deploy
    ```

This will update your website with the latest changes.

---

## Features

- **Homepage**: Displays an introduction and showcases featured skills.
- **Project Page**: Highlights projects with descriptions and images.
- **Blog**: Dynamic content fetched from Firebase, showing blog posts.
- **About & Skills**: Sections to display personal information and technical skills.
- **Experience**: Displays work experience from local JSON files.
- **Firebase Integration**: Fetches dynamic data such as blog posts and projects directly from Firebase.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Feel free to modify or extend the project to suit your needs! If you have any questions or feedback, feel free to open an issue or contact me directly.

---
