require 'cry/wasmtime'
require 'gr'

Cry::Wasm.runtime = Cry::Wasmtime

class CliffordAttractor
  extend Cry::Wasm

  cry [], 'Array(Float64)'
  def calc
    n = 500_000_00
    x0 = 0.0
    y0 = 0.0
    a = -1.3
    b = -1.3
    c = -1.8
    d = -1.9
    dθ = 0.007

    x = [x0]
    y = [y0]
    θ = 0.007

    n.times do |i|
      x <<  (Math.sin(a * y[i]) + c * Math.cos(a * x[i])) * Math.cos(θ)
      y <<  (Math.sin(b * x[i]) + d * Math.cos(b * y[i])) * Math.cos(θ)
      θ += dθ
    end

    x.concat(y)
  end

  cry_build
end

xy = CliffordAttractor.new.calc
x = xy[0..500_000_00]
y = xy[500_000_01..-1]

GR.setviewport(0, 1, 0, 1)
GR.setwindow(-3, 3, -3, 3)
GR.setcolormap(8)
GR.shadepoints(x, y, dims: [480, 480], xform: 5)
GR.updatews
gets
