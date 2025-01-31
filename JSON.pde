/**************************************************
*These functions save the slider positions
*The seed and save them under a name
*They also load the json file if needed
**************************************************/
void setJSON(String name){
  JSONObject Jslider = new JSONObject();
  for(int s = 0; s < sH.sliders.size(); s++){
     Jslider.setFloat(str(s),sH.getPerc(s));
  }
  Jslider.setInt("Seed",seed);
  
  addJSON(name,Jslider); //<>//
}

JSONObject getJSONALL() {
  JSONObject json = new JSONObject();
  json = loadJSONObject("data/new.json");
  return json;
}

JSONObject getJSON(String name){
   JSONObject json = getJSONALL();
  return json.getJSONObject(name);
}

void addJSON(String name, JSONObject obj){
  //JSONObject json = new JSONObject();
  JSONObject json = getJSONALL();  //<>//
  json.setJSONObject(name, obj);
  saveJSONObject(json,"data/new.json"); //<>//
} //<>//
