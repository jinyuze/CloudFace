# This Python file uses the following encoding: utf-8
__author__ = 'xiaohe'
import os

#!/usr/bin/env python

import sys
import os.path

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print "usage: create_csv <base_path>"
        sys.exit(1)

    BASE_PATH=sys.argv[1]
    SEPARATOR=";"
    f = open('face.csv','w')
    label = 0
    for dirname, dirnames, filenames in os.walk(BASE_PATH):
        for subdirname in dirnames:
            picture_label = 0
            subject_path = os.path.join(dirname, subdirname)
            for filename in os.listdir(subject_path):
                abs_path = "%s/%s" % (subject_path, filename)
                print "%s%s%d" % (abs_path, SEPARATOR, label)
                new_path = 'cutted_face/'+label.__str__()+'/'
                if not os.path.exists(new_path):
                    os.makedirs(new_path)
                new_image = new_path+picture_label.__str__()+'.png'
                #print new_image
                cmd = './facedetect '+abs_path+" "+new_image+" "+new_image+ " >/dev/null 2>&1"
                #print cmd
                out = os.system(cmd)
                print "%s%s%d" % (new_image, SEPARATOR, label)
                f.write("%s%s%d\n" % (new_image, SEPARATOR, label))
                picture_label += 1
            label = label + 1
