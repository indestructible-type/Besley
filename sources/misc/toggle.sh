if grep -q 'Black"' "../designspace/Besley.designspace"; then
  echo "Besley to Besley*"

  sed -i 's/Besley-Regular/Besley-Book/g' ../build-woff2.sh

  sed -i 's/Besley/Besley\*/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley Italic"/Besley Book Italic"/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Black /Fatface /g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley\* Italic/Besley\* Book Italic/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley\*-/Besley-/g' ../designspace/Besley-Italic.designspace

  sed -i 's/Besley/Besley\*/g' ../designspace/Besley.designspace
  sed -i 's/Regular"/Book"/g' ../designspace/Besley.designspace
  sed -i 's/Black"/Fatface"/g' ../designspace/Besley.designspace
  sed -i 's/Besley\*-/Besley-/g' ../designspace/Besley.designspace

  sed -i 's/"Besley Regular"/"Besley\\\* Book"/g' ../build-variable.sh
  sed -i 's/"Besley Black"/"Besley\\\* Black"/g' ../build-variable.sh
  sed -i 's/"Besley Italic"/"Besley\\\* Book Italic"/g' ../build-variable.sh
  sed -i 's/"Besley Black Italic"/"Besley\\\* Black Italic"/g' ../build-variable.sh

  sed -i 's/Besley/Besley\*/g' ../UFO/Besley-Regular.ufo/fontinfo.plist
  sed -i 's/Regular/Book/g' ../UFO/Besley-Regular.ufo/fontinfo.plist
  sed -i 's/Besley/Besley\*/g' ../UFO/Besley-Italic.ufo/fontinfo.plist
  sed -i 's/Italic/Book Italic/g' ../UFO/Besley-Italic.ufo/fontinfo.plist

elif grep -q 'Fatface"' "../designspace/Besley.designspace"; then
  echo "Besley* to Besley"

  sed -i 's/Besley-Book/Besley-Regular/g' ../build-woff2.sh

  sed -i 's/Besley\*/Besley/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Book Italic"/Italic"/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Fatface /Black /g' ../designspace/Besley-Italic.designspace

  sed -i 's/Besley\*/Besley/g' ../designspace/Besley.designspace
  sed -i 's/Book/Regular/g' ../designspace/Besley.designspace
  sed -i 's/Fatface"/Black"/g' ../designspace/Besley.designspace

  sed -i 's/"Besley\\\* Book"/"Besley Regular"/g' ../build-variable.sh
  sed -i 's/"Besley\\\* Black"/"Besley Black"/g' ../build-variable.sh
  sed -i 's/"Besley\\\* Book Italic"/"Besley Italic"/g' ../build-variable.sh
  sed -i 's/"Besley\\\* Black Italic"/"Besley Black Italic"/g' ../build-variable.sh

  sed -i 's/Besley\*/Besley/g' ../UFO/Besley-Regular.ufo/fontinfo.plist
  sed -i 's/Book/Regular/g' ../UFO/Besley-Regular.ufo/fontinfo.plist
  sed -i 's/Besley\*/Besley/g' ../UFO/Besley-Italic.ufo/fontinfo.plist
  sed -i 's/Book Italic/Italic/g' ../UFO/Besley-Italic.ufo/fontinfo.plist
fi
