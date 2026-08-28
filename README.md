<p align="center">
 <img align="center" width=100% alt="Boorusama Logo" src="https://user-images.githubusercontent.com/19619099/177544952-1d963e91-5c6d-40d2-b731-bf84b63aa246.png" />
</p>

## Overview

Boorusama is an unofficial, cross-platform client for major booru imageboards. It covers all core functionality and gives you total control over your experience with extra features like bulk downloads, favorite tags, advanced blacklisting, and more.

### Fork differences

This is a fork of the original [Boorusama](https://github.com/khoadng/Boorusama) with the following changes:

- **Subdirectory downloads** — save files into nested folders based on tags or custom text in the filename template.  
  Slashes (`/`) in the filename format are now interpreted as directory separators.  
  Example: if the download path is `/booru` and the filename is `{artist}/{id}.jpg`, the file will be saved as `/booru/artist_name/12345.jpg`. Empty tags and path traversal attempts (`../`, leading/trailing slashes) are automatically sanitized.
- Only **Android** and **GNU/Linux** are supported by the automated GitHub Actions builds. I don’t use other platforms, and I can’t guarantee full compatibility with them if major changes are introduced in the future. If you need a build for a platform not covered by the automated builds, you can compile the source code manually.  
- Android now uses a new package name to avoid conflicts with the main app, in case you need to install both.  

![Banner_1](./images/banner_2.png)  
![Banner_2](./images/banner_1.png)

## Features

Supported imageboards:
- Danbooru
- Gelbooru 0.2.5, Gelbooru 0.1, Gelbooru 0.2
- e621ng
- e-shushuu
- Zerochan
- Moebooru
- Nozomi.la
- Shimmie2
- Sankaku
- Philomena
- Szurubooru
- Hydrus Network
- Hybooru
- anime-pictures

## Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/downloads)

### Steps
1. Clone the repository:
```bash
git clone https://github.com/khoadng/Boorusama.git
cd Boorusama
```
2. Install dependencies and generate boilerplate code:
```bash
./init.sh
```
3. Connect to an Android device or emulator and run the app:
```bash
flutter run --release
```
Or build an APK and install it manually:
```bash
./build.sh apk --flavor prod
```
