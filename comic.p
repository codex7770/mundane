# Importing modules
import requests
from bs4 import BeautifulSoup
from zipfile import ZipFile
import tkinter as tk
from tkinter import ttk
from tkinter import filedialog
from tkinter import messagebox

# Defining constants
BASE_URL = "https://ksk.moe/"
ZIP_NAME = "gallery.zip"

# Defining functions
def get_images(url):
    """Returns a list of image urls from the given url"""
    # Sending a get request to the url
    response = requests.get(url)
    # Checking if the response is successful
    if response.status_code == 200:
        # Parsing the html content with BeautifulSoup
        soup = BeautifulSoup(response.content, "html.parser")
        # Finding all the image elements inside the body tag
        images = soup.body.find_all("img")
        # Logging the number of images found
        log(f"Found {len(images)} images")
        # Extracting the image urls and appending them to a list
        image_urls = []
        for image in images:
            image_url = BASE_URL + image["src"]
            image_urls.append(image_url)
        # Returning the list of image urls
        return image_urls
    else:
        # Logging the error message and raising an exception
        log(f"Error: {response.status_code}")
        raise Exception(f"Failed to get the page")

def download_images(image_urls):
    """Downloads the images from the given urls and saves them in a zip file"""
    # Creating a zip file object in write mode
    with ZipFile(ZIP_NAME, "w") as zip_file:
        # Looping through the image urls
        for i, image_url in enumerate(image_urls):
            # Sending a get request to the image url
            response = requests.get(image_url)
            # Checking if the response is successful
            if response.status_code == 200:
                # Extracting the image name from the url
                image_name = image_url.split("/")[-1]
                # Writing the image content to the zip file with the image name
                zip_file.writestr(image_name, response.content)
                # Logging the progress and updating the progress bar
                log(f"Downloaded {image_name}")
                progress_bar["value"] = (i + 1) / len(image_urls) * 100
                root.update()
            else:
                # Logging the error message and skipping the image
                log(f"Error: {response.status_code} for {image_url}")
    # Logging the completion message and showing a message box
    log(f"Saved {ZIP_NAME} in the current directory")
    messagebox.showinfo("Success", f"Saved {ZIP_NAME} in the current directory")

def log(message):
    """Appends a message to the log box with a newline"""
    log_box.insert(tk.END, message + "\n")
    log_box.see(tk.END)

def browse():
    """Opens a file dialog to select a directory and sets it as the current directory"""
    directory = filedialog.askdirectory()
    if directory:
        os.chdir(directory)
        log(f"Changed directory to {directory}")

def start():
    """Starts the downloading process
