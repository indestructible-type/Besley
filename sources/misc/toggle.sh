if grep -q 'Black"' "../designspace/Besley.designspace"; then
  echo "Besley to Besley*"

  sed -i 's/Besley-Regular/Besley-Book/g' ../build-woff2.sh

  sed -i 's/Besley"/Besley\*"/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley /Besley\* /g' ../designspace/Besley-Italic.designspace
  sed -i 's/Black/Fatface/g' ../designspace/Besley-Italic.designspace
  sed -i 's/SemiBold/Semi/g' ../designspace/Besley-Italic.designspace
  sed -i 's/ExtraBold/Heavy/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley\* Italic/Besley\* Book Italic/g' ../designspace/Besley-Italic.designspace
  sed -i 's/"Italic"/"Book Italic"/g' ../designspace/Besley-Italic.designspace
  sed -i 's/instance_ufo\/Besley-Italic.ufo/instance_ufo\/Besley-BookItalic.ufo/g' ../designspace/Besley-Italic.designspace

  sed -i 's/Besley"/Besley\*"/g' ../designspace/Besley.designspace
  sed -i 's/Besley /Besley\* /g' ../designspace/Besley.designspace
  sed -i 's/Black/Fatface/g' ../designspace/Besley.designspace
  sed -i 's/Regular/Book/g' ../designspace/Besley.designspace
  sed -i 's/SemiBold/Semi/g' ../designspace/Besley.designspace
  sed -i 's/ExtraBold/Heavy/g' ../designspace/Besley.designspace

elif grep -q 'Fatface"' "../designspace/Besley.designspace"; then
  echo "Besley* to Besley"

  sed -i 's/Besley-Book/Besley-Regular/g' ../build-woff2.sh

  sed -i 's/Besley\*"/Besley"/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley\* /Besley /g' ../designspace/Besley-Italic.designspace
  sed -i 's/Fatface/Black/g' ../designspace/Besley-Italic.designspace
  sed -i 's/\/ufo\/Besley-Black/\/ufo\/Besley-Fatface/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Semi/SemiBold/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Heavy/ExtraBold/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Besley* Italic/Besley* Book Italic/g' ../designspace/Besley-Italic.designspace
  sed -i 's/Book Italic/Italic/g' ../designspace/Besley-Italic.designspace
  sed -i 's/BookItalic/Italic/g' ../designspace/Besley-Italic.designspace

  sed -i 's/Besley\*"/Besley"/g' ../designspace/Besley.designspace
  sed -i 's/Besley\* /Besley /g' ../designspace/Besley.designspace
  sed -i 's/Fatface/Black/g' ../designspace/Besley.designspace
  sed -i 's/Book/Regular/g' ../designspace/Besley.designspace
  sed -i 's/Semi/SemiBold/g' ../designspace/Besley.designspace
  sed -i 's/Heavy/ExtraBold/g' ../designspace/Besley.designspace
  sed -i 's/\/ufo\/Besley-Black/\/ufo\/Besley-Fatface/g' ../designspace/Besley.designspace
  sed -i 's/\/ufo\/Besley-Regular/\/ufo\/Besley-Book/g' ../designspace/Besley.designspace
  sed -i 's/\/ufo\/BesleyCondensed-Black/\/ufo\/BesleyCondensed-Fatface/g' ../designspace/Besley.designspace
  sed -i 's/\/ufo\/BesleyCondensed-Regular/\/ufo\/BesleyCondensed-Book/g' ../designspace/Besley.designspace
fi
