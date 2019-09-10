import os
import parsecsv
import strutils
import plotly


proc plot_csv(header: seq[string], x_axis: seq[float], y_axis: seq[float]) = 
  var d = Trace[float](mode: PlotMode.Markers, `type`: PlotType.Scatter)
  var size = @[16.float]
  d.marker =Marker[float](size:size)
  d.xs = x_axis
  d.ys = y_axis
  d.text = @["hello", "data-point", "third", "highest", "<b>bold</b>"]
  var layout = Layout(title: "testing", width: 1200, height: 600,
                      xaxis: Axis(title: header[0]),
                      yaxis: Axis(title: header[1]), autosize:true)
  
  var p = Plot[float](layout:layout, traces: @[d])
  # 保存图像
  if not existsDir("./generate"):
    createDir("./generate")
  # run with --threads:on
  p.show(filename="generate/display.png")



proc read_and_plot(filename="./test.csv") = 
  var parser: CsvParser
  parser.open(fileName)
  parser.readHeaderRow()
  let header = parser.headers 
  var x_axis: seq[float] = @[]
  var y_axis: seq[float] = @[]
  while parser.readRow:
    let x = parser.row[0]
    let y = parser.row[1]
    x_axis.add(x.parseFloat)
    y_axis.add(y.parseFloat)
  close(parser)
  plot_csv(header, x_axis, y_axis)


read_and_plot()