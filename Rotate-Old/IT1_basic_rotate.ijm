macro "Rotate Image" {
      requires("1.33o");
      getLine(x1, y1, x2, y2, width);
      if (x1==-1)
           exit("This macro requires a straight line selection");
      angle = (180.0/PI)*atan2(y1-y2, x2-x1);
      run("Arbitrarily...", "angle="+angle+" interpolate");
  }