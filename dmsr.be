class DSMR
var codes
var topic
var pwr

def init()
 self.codes={"1-0:1.8.1":"enrg_imp_t1","1-0:1.8.2":"enrg_imp_t2","1-0:2.8.1":"enrg_exp_t1","1-0:2.8.2":"enrg_exp_t2","0-0:96.14.0":"tariff","1-0:1.7.0":"pwr_imp","1-0:2.7.0":"pwr_exp","1-0:32.7.0":"volts_l1","1-0:52.7.0":"volts_l2","1-0:72.7.0":"volts_l3","1-0:31.7.0":"amps_l1","1-0:51.7.0":"amps_l2","1-0:71.7.0":"amps_l3","1-0:21.7.0":"l1_pwr_imp","1-0:41.7.0":"l2_pwr_imp","1-0:61.7.0":"l3_pwr_imp","1-0:22.7.0":"l1_pwr_exp","1-0:42.7.0":"l2_pwr_exp","1-0:62.7.0":"l3_pwr_exp"}
 self.topic="tele/"+tasmota.cmd("topic")["Topic"]+"/DSMR5"
 self.pwr=1
 tasmota.remove_rule("SerialReceived")
 tasmota.add_rule("SerialReceived",/v,t,p -> self.decode(v,t,p))
end #init

def decode(value, trigger, payload)
  import string
  import mqtt

  var msg=string.split(str(value),"\r\n")
  var mqttmap=map()
  for it: msg
    var itlist=string.split(str(it),"(",1)
    var key=self.codes.find(itlist[0])
    if (key!=nil)
      var val=string.split(itlist[1],size(itlist[1])-1)[0]
      val=string.split(val,"*")[0]
      mqttmap.insert(key,number(val))
    end
  end
  if (self.codes.size()==mqttmap.size())
    mqtt.publish(self.topic, string.tr(str(mqttmap),""","""))
    self.pwr=(mqttmap["pwr_exp"]-mqttmap["pwr_imp"])
  end
end #decode

def every_second()
 var hue=self.pwr>0 ? 120 : 0
 var bri=self.pwr>0 ? int(self.pwr*255/10) : -int(self.pwr*255/20)
# print(f"bri: {bri}, hue: {hue}")
 light.set({"bri":bri,"hue":hue,"sat":255})
end #every_second


end #DSMR

var dsmr=DSMR()
tasmota.add_driver(dsmr)