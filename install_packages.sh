#!/bin/bash

read -p "This script will automatically install the dependencies (Python, R packages, rate4site). Continue? (Y/n) " choix_installation

if [ "$choix_installation" != "Y" ]; then 
    echo "Installation aborted."
    exit 1
fi

OS=$(uname)

if [[ "$OS" == "Darwin" ]]; then
    echo "macOS detected."

    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    brew update

    for pkg in libxml2 openssl freetype harfbuzz fribidi libpng libtiff jpeg gcc wget r python-tk@3.11; do
        if brew list --formula | grep -q "^$pkg$"; then
            echo "$pkg is already installed."
        else
            echo "Installing $pkg..."
            brew install "$pkg"
        fi
    done

    echo "\n🔁 Cleaning any previous rate4site installation..."
    sudo rm -f /usr/local/bin/rate4site
    sudo rm -f /opt/homebrew/bin/rate4site

    echo "📦 Unzipping fresh rate4site source..."
    rm -rf dependencies/rate4site_src
    unzip -o dependencies/rate4site.3.2.source.zip -d dependencies/rate4site_src

    RATE_DIR=$(find dependencies/rate4site_src -type f -name Makefile_slow -exec dirname {} \; | head -n 1)

    if [ -z "$RATE_DIR" ]; then
        echo "❌ Error: Makefile_slow not found. Cannot compile rate4site."
        exit 1
    fi

    echo "🛠 Compiling rate4site..."
    cd "$RATE_DIR" || exit 1
    make -f Makefile_slow

    if [[ ! -f rate4site ]]; then
        echo "❌ Compilation failed: rate4site binary not found."
        exit 1
    fi

    echo "📂 Copying rate4site to /opt/homebrew/bin..."
    sudo cp rate4site /opt/homebrew/bin/rate4site
    sudo chmod +x /opt/homebrew/bin/rate4site
    cd ../../../../

    touch "$HOME/.zprofile"
    if ! grep -q 'export PATH="/opt/homebrew/bin:$PATH"' "$HOME/.zprofile"; then
        echo 'export PATH="/opt/homebrew/bin:$PATH"' >> "$HOME/.zprofile"
        echo "✅ Added /opt/homebrew/bin to your PATH in ~/.zprofile"
    fi

elif [[ "$OS" == "Linux" ]]; then
    echo "Linux detected."
    sudo apt update
    REQUIRED_PKGS=(
        libcurl4-openssl-dev libxml2-dev libssl-dev
        libfontconfig1-dev libharfbuzz-dev libfribidi-dev
        libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
        g++-11 wget python3-tk rate4site
    )
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if dpkg -s "$pkg" &> /dev/null; then
            echo "$pkg is already installed."
        else
            echo "Installing $pkg..."
            sudo apt install -y "$pkg"
        fi
    done
else
    echo "Unsupported OS."
    exit 1
fi

# Python: customtkinter
if python3 -c "import customtkinter" &> /dev/null; then
    echo "customtkinter already installed."
else
    python3 -m pip install --upgrade pip
    python3 -m pip install customtkinter
fi

# R: Makevars CXX11
if [[ "$OS" == "Darwin" ]]; then
    mkdir -p ~/.R
    echo "CXXFLAGS += -std=c++11" >> ~/.R/Makevars
fi

# R package installation functions
install_r_package_if_missing() {
    local pkg="$1"
    if Rscript -e "if (!requireNamespace('$pkg', quietly = TRUE)) quit(status = 1)" &> /dev/null; then
        echo "$pkg already installed."
    else
        echo "Installing $pkg from source..."
        Rscript -e "install.packages('$pkg', repos='http://cran.rstudio.com/', type='source')"
    fi
}

install_bioc_package_if_missing() {
    local pkg="$1"
    if Rscript -e "if (!requireNamespace('$pkg', quietly = TRUE)) quit(status = 1)" &> /dev/null; then
        echo "$pkg already installed."
    else
        echo "Installing Bioconductor package: $pkg..."
        Rscript -e "BiocManager::install('$pkg')"
    fi
}

# Tidyverse via binary or fallback
if [[ "$OS" == "Darwin" ]]; then
    TIDY_BINARY_URL="https://cran.r-project.org/bin/macosx/big-sur-arm64/contrib/4.5/tidyverse_2.0.0.tgz"
    TIDY_BINARY_PATH="/tmp/tidyverse_2.0.0.tgz"

    if Rscript -e "if (!requireNamespace('tidyverse', quietly = TRUE)) quit(status = 1)" &> /dev/null; then
        echo "tidyverse already installed."
    else
        echo "Downloading tidyverse binary for macOS..."
        curl -L "$TIDY_BINARY_URL" -o "$TIDY_BINARY_PATH"

        echo "Installing tidyverse from binary..."
        Rscript -e "install.packages('$TIDY_BINARY_PATH', repos = NULL, type = 'mac.binary')"
    fi
else
    install_r_package_if_missing "tidyverse"
fi

# Other R packages needed for the Python tool
install_r_package_if_missing "BiocManager"
install_r_package_if_missing "bio3d"
install_r_package_if_missing "msa"
install_r_package_if_missing "readr"
install_r_package_if_missing "dplyr"

# msa and its Bioconductor deps
if Rscript -e "if (!requireNamespace('msa', quietly = TRUE)) quit(status = 1)" &> /dev/null; then
    echo "msa already installed."
else
    echo "Installing msa and dependencies..."
    install_bioc_package_if_missing "BiocGenerics"
    install_bioc_package_if_missing "IRanges"
    install_bioc_package_if_missing "S4Vectors"
    install_bioc_package_if_missing "Biostrings"
    install_bioc_package_if_missing "msa"
fi

# Final check
if command -v rate4site &> /dev/null; then
    echo -e "\n✅ rate4site successfully installed at: $(which rate4site)"
    rate4site -h | head -n 5
else
    echo "❌ rate4site not found in PATH."
fi

echo "\n✅ All required packages have been successfully installed."
