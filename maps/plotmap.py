#Load Python packages and functions
import shapefile as shp
import numpy as np
import matplotlib.pyplot as plt

#Load shapefile into Python
shp_file_base='regions'
dat_dir='../shapefiles/'+shp_file_base +'/'
sf = shp.Reader(dat_dir+shp_file_base)

print 'number of shapes imported:',len(sf.shapes())
print ' '
print 'geometry attributes in each shape:'
for name in dir(sf.shape()):
   if not name.startswith('_'):
	print name

#Plot Figure

plt.figure()
ax = plt.axes()
ax.set_aspect('equal')
for shape in list(sf.iterShapes()):
   x_lon = np.zeros((len(shape.points),1))
   y_lat = np.zeros((len(shape.points),1))
   for ip in range(len(shape.points)):
      x_lon[ip] = shape.points[ip][0]
      y_lat[ip] = shape.points[ip][0]

   plt.plot(x_lon,y_lat)
plt.xlim(-130,-60)
plt.ylim(23,50)
