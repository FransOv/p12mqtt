class DSMR
static var codes={'1-0:1.8.1':'enrg_imp_t1','1-0:1.8.2':'enrg_imp_t2','1-0:2.8.1':'enrg_exp_t1','1-0:2.8.2':'enrg_exp_t2','0-0:96.14.0':'tariff','1-0:1.7.0':'pwr_imp','1-0:2.7.0':'pwr_exp','1-0:32.7.0':'volts_l1','1-0:52.7.0':'volts_l2','1-0:72.7.0':'volts_l3','1-0:31.7.0':'amps_l1','1-0:51.7.0':'amps_l2','1-0:71.7.0':'amps_l3','1-0:21.7.0':'l1_pwr_imp','1-0:41.7.0':'l2_pwr_imp','1-0:61.7.0':'l3_pwr_imp','1-0:22.7.0':'l1_pwr_exp','1-0:42.7.0':'l2_pwr_exp','1-0:62.7.0':'l3_pwr_exp'}

var serialbuf
var ser
var mqttmap
var enrg_imp
var enrg_exp
var pwr
var topic

def init()
 tasmota.set_power(0,false)
 self.serialbuf=""
 self.ser=serial(20,-1,115200,serial.SERIAL_8N1)
 self.ser.flush()
 tasmota.set_power(0,true)
 self.mqttmap=map()
 self.topic='tele/'+tasmota.cmd('topic')['Topic']+'/DSMR5'
 self.enrg_imp=0
 self.enrg_exp=0
 self.pwr=1
end #init

def every_50ms()
 import string
 if self.ser.available()>0
  self.serialbuf+=self.ser.read().asstring()
  var newline=string.find(self.serialbuf,"\n")
  while newline!=-1
   var datagram=self.serialbuf[0..newline]
   if size(self.serialbuf)>newline
    self.serialbuf=self.serialbuf[newline+1..]
   else
    self.serialbuf=""
   end
   self.decode(datagram)
   newline=string.find(self.serialbuf,"\n")
  end
 end

end #every_50ms

def decode(value)
 import string
# print(value)
 var item=string.split(value,'(',1)
 var key=self.codes.find(item[0])
 if key!=nil
  var val=string.split(item[1],size(item[1])-1)[0]
  val=string.split(val,'*')[0]
  if self.mqttmap.find(key)!=nil
   self.mqttmap[key]=number(val)
  else
   self.mqttmap.insert(key,number(val))
  end
 end

end #decode

def every_second()
 import mqtt
 import math
 import string
 if (self.codes.size()==self.mqttmap.size())
  global.dataValid=true
  if (self.enrg_imp==0) self.enrg_imp=self.mqttmap["enrg_imp_t1"]+self.mqttmap["enrg_imp_t2"] end
  if (self.enrg_exp==0) self.enrg_exp=self.mqttmap["enrg_exp_t1"]+self.mqttmap["enrg_exp_t2"] end
  if (math.abs((self.mqttmap["enrg_imp_t1"]+self.mqttmap["enrg_imp_t2"])-self.enrg_imp)<10 && math.abs((self.mqttmap["enrg_exp_t1"]+self.mqttmap["enrg_exp_t2"])-self.enrg_exp)<10)
   mqtt.publish(self.topic, string.tr(str(self.mqttmap),"'",'"'))
   self.enrg_imp=self.mqttmap["enrg_imp_t1"]+self.mqttmap["enrg_imp_t2"]
   self.enrg_exp=self.mqttmap["enrg_exp_t1"]+self.mqttmap["enrg_exp_t2"]
   self.pwr=(self.mqttmap["pwr_exp"]-self.mqttmap["pwr_imp"])
  end
 end

end #every_second

def web_sensor()
 import string
 var pwrshow=string.format("{s}Power:{m}%.3f{e}{s}Energy import:{m}%.3f{e}{s}Energy Export:{m}%.3f{e}",self.pwr,self.enrg_imp,self.enrg_exp)
 tasmota.web_send(pwrshow)
end #web_sensor


end #DSMR

var dsmr=DSMR()
tasmota.add_driver(dsmr)
