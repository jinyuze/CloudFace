# This Python file uses the following encoding: utf-8
from flask import Flask
import os
import subprocess
import cv2
from tempfile import mktemp
from flask import Flask, request, render_template, redirect, url_for

UPLOAD_FOLDER = 'uploads'
FACE_FOLDER = 'faces'
ALLOWED_MIMETYPES = {'image/jpeg', 'image/png', 'image/gif'}

app = Flask(__name__)
model = cv2.createEigenFaceRecognizer()
model.load("eigenfaces_at.yml")

@app.route('/',methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':
        f = request.files['file']
        fname = mktemp(suffix='_', prefix='u', dir=UPLOAD_FOLDER) + '.png'
        f.save(fname)
        result = faceRecognize(fname)
        return result
    else:
         return render_template('upload.html')
# @app.route('/',methods=['GET', 'POST'])
# def hello_world():
#     # proc = subprocess.Popen(["./recognizer"], stdout=subprocess.PIPE, shell=True)
#     # (out, err) = proc.communicate()
#     # print "program output:", out
#     # return out
#     return
def faceRecognize(filename):
    im = cv2.imread(filename, cv2.IMREAD_GRAYSCALE)
    res = cv2.resize(im, (92,112), 0, 0, cv2.INTER_CUBIC)
    [p_label, p_confidence] = model.predict(res)
    result = "Predicted label = %d (confidence=%.2f)" % (p_label, p_confidence)
    return result
if __name__ == '__main__':
    app.run('101.5.209.132')
