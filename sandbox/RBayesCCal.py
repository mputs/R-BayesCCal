from BayesCCal import calibrator_binary, WatermanEst
import numpy as np

class Rcalibrator_binary(calibrator_binary):
    def __init__(self, bins = 3, radius = .1, pisamples=1001, density="Waterman"):
            self.bins = bins;
            self.radius = radius;
            self.pisamples = pisamples
            if density == "hist":
                self.density_t = __HistEst__(bins = bins)
                self.density_f = __HistEst__(bins = bins)
            elif density == "dens":
                self.density_t = __DensEst__(radius = radius)
                self.density_f = __DensEst__(radius = radius)
            elif density == "Waterman":
                self.density_t = WatermanEst()
                self.density_f = WatermanEst()
            elif isinstance(density, tuple):
                if len(density) == 2:
                    def __checkattr__(density):
                        try:
                            assert(hasattr(density, "pdf"))
                            assert(hasattr(density, "init"))
                        except:
                            return -1
                        return 0
                    if not __checkattr__(density[0]):
                        self.density_t = density[0]
                    else: 
                        raise Exception("first object in density argument is not an expected object" )
                    if not __checkattr__(density[1]):
                        self.density_f = density[1]
                    else:
                        raise Exception("second object in density argument is not an expected object")
                else:
                    raise Exception("density must be \"hist\", \"est\", or a tuple of objects having an init() method and a pdf() method")
                
            else:
                raise Exception("non valid argument for density: {}".format(density))
    def calcDensities(self, p, y):
        p = np.array(p)
        y = np.array(y)
        print(p.shape,y.shape)
        pxt = p[y==1]
        pxf = p[y==0]        
        self.density_t.init(pxt);
        self.density_f.init(pxf);
        self.n = p.shape[0];
        
    def getProportion(self, proba):
        """
        Get proportion positives in dataset
        
        Parameters
        ----------
        p: same shape as needed for classifier
            samples to be classified
        
        Returns
        -------
        Proportion positives in dataset (float)
        """
        proba = np.array(proba)
        pi = self.__maxLike__(proba)
        self.pi = pi
        return pi
        
    def predict_proba(self, P):
        proba = np.array(P)
        pt = self.density_t.pdf(proba)
        pf = self.density_f.pdf(proba)
        self.pi = self.__maxLike__(proba)
        p = self.pi*pt/(self.pi*pt+(1-self.pi)*pf)
        p = p.reshape(p.shape[0],1)
        return np.hstack([1-p,p]);
      
      
