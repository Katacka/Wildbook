package org.ecocean;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.io.File;

import org.ecocean.movement.SurveyTrack;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.apache.commons.lang3.builder.ToStringBuilder;
import jxl.write.*;
import jxl.Workbook;

import org.ecocean.movement.*;
/**
* This is an object that contains occurrences and survey tracks, with specific
* geographic points that were traversed. It is intended to be a measure of the work 
* spent to collect data, and a way of relating media assets to a specific period of 
* collection. 
*
* 2017
* @author Colin Kingen
*/

public class Survey implements java.io.Serializable{
  
  /**
   * 
   */
  private static final long serialVersionUID = -5028529439301775287L;
  private ArrayList<SurveyTrack> surveyTracks;
  
  private String surveyID;
  private String project;
  private String organization;
  private String comments = "None";
  private String type;
  private Long startTime = null;
  private Long endTime = null;
  // This is the actual amount of effort spent to gather date. 
  private Measurement effort;
  
  private String dateTimeCreated;
  private String dateTimeModified;
  
  private String date;
  
  private ArrayList<Observation> observations = new ArrayList<Observation>();
  

    public Survey() {
        generateID();
        this.surveyTracks = new ArrayList<SurveyTrack>();
        setDateTimeCreated();
        setDWCDateLastModified();
    }

    public Survey(DateTime startTime) {
        this();
        if (startTime != null) {
            this.date = startTime.toString();
            this.startTime = startTime.getMillis();
        }
    }

  public Survey(String date){
    this.date=date;
    generateID();
    this.surveyTracks = new ArrayList<SurveyTrack>();
    setDateTimeCreated();
    setDWCDateLastModified();
  }
  
  public void setDate(String newDate) {
    date = newDate;
  }
  
  public String getDate() {
    if (date != null) {
      return date;      
    }
    return null;
  }
  
  public String getDateTimeCreated() {
    if (dateTimeCreated != null) {
      return dateTimeCreated;
    }
    return "";
  }

  public void setDateTimeCreated(String time) {
    dateTimeCreated = time;
  }

  public void setDateTimeCreated() {
        dateTimeCreated = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
  }
  
  public String getDWCDateLastModified() {
    return dateTimeModified;
  }

  public void setDWCDateLastModified(String lastModified) {
    dateTimeModified = lastModified;
  }

  public void setDWCDateLastModified() {
    dateTimeModified = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
  }
    
  public String getComments() {
    if (comments != null) {
      return comments;
    } else {
      return "None";
    }
  }
  
  public void addComments(String newComments) {
    try {
      if (comments != null && !comments.equals("None")) {
        comments += newComments;
      } else {
        comments = newComments;
      }
      setDWCDateLastModified();      
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  public String getID() {
    if (surveyID != null) {
      return surveyID;
    } else {
      return null;
    }
  }
  
  public void setID(String newID) {
    surveyID = newID;
    setDWCDateLastModified();
  }
  
  public void generateID() {
    String id = Util.generateUUID().toString();  
    surveyID = id;
  }
  
    public ArrayList<SurveyTrack> getSurveyTracks() {
        return surveyTracks;
    }

    public int numSurveyTracks() {
        if (surveyTracks == null) return 0;
        return surveyTracks.size();
    }

    //TODO what does this method do (differently than getSurveyTracks()) ???    -jon
  public ArrayList<SurveyTrack> getAllSurveyTracks() {
    if (surveyTracks == null) return null;
    if (!surveyTracks.isEmpty()) {
     return surveyTracks; 
    } else {
      return null;
    }
  }
  
  public SurveyTrack getSurveyTrackByID(String id) {
    if (surveyTracks == null) return null;
    for (int i=0; i<surveyTracks.size(); i++) {
      SurveyTrack thisTrack = surveyTracks.get(i);
      if (thisTrack.getID().equals(id)) {
        return thisTrack;
      }
    }
    return null;
  }
  
  public void addSurveyTrack(SurveyTrack thisTrack) {
    if (surveyTracks == null) surveyTracks = new ArrayList<SurveyTrack>();
    if (thisTrack != null) {
        //little wonky, but arguable the "occ.correspondingSurvey" itself is wonky, see FK rants etc
        if (thisTrack.getOccurrences() != null) {
            for (Occurrence occ : thisTrack.getOccurrences()) {
                occ.setCorrespondingSurveyID(this.getID());
            }
        }
      surveyTracks.add(thisTrack);
      setDWCDateLastModified();
    }
  }
  
  public void addMultipleSurveyTrack(ArrayList<SurveyTrack> trackArray) {
    if (surveyTracks == null) surveyTracks = new ArrayList<SurveyTrack>();
    if (trackArray.size() >= 1) {
      for (int i=0; i<trackArray.size(); i++) {
        surveyTracks.add(trackArray.get(i));
      }
    setDWCDateLastModified();
    }
  }
    
  public void setProjectName(String proj) {
    if (proj != null && !proj.equals("")) {
      project = proj;
      setDWCDateLastModified();
    }
  }
  
  public String getProjectName() {
    if (project != null && !project.equals("")) {
      return project;
    } else {
      return null;
    }
  }
  
  public void setOrganization(String org) {
    if (org != null && !org.equals("")) {
      organization = org;
      setDWCDateLastModified();
    }
  }
  
  public String getOrganization() {
    if (organization != null && !organization.equals("")) {
      return organization;
    } else {
      return null;
    }
  }
  
  public void setProjectType(String typ) {
    if (typ != null && !typ.equals("")) {
      type = typ;
      setDWCDateLastModified();
    }
  }
  
  public String getProjectType() {
    if (type != null && !type.equals("")) {
      return type;
    } else {
      return null;
    }
  }
  
  public Measurement getEffort() {
    if (effort != null) {
      return effort;
    }
    return null;
  }
  
  public void setEffort(Measurement eff) {
    if (eff.getUnits() != null) {
      effort = eff;
      setDWCDateLastModified();
    }
  }
  
  public void setStartTimeMilli(Long i) {
    if (i > 0) {
      startTime = i;
    }
  }
  
  public String getStartTimeMilli() {
    if (startTime != null && startTime > 0) {
      return startTime.toString();
    }
    return null;
  }
    public Long getStartTime() {
        return startTime;
    }
  
  public void setEndTimeMilli(Long et) {
    if (et > 0) {
      startTime = et;
    }
  }
  
  public void setEndTimeWithDate(String date) {
    String milli =  monthDayYearToMilli(date);
    try {
      Long m = Long.valueOf(milli); 
      endTime = Math.abs(m);      
    } catch (Exception e) {
      e.printStackTrace();
      System.out.println("Failed to Set endTime from dateString.");
    }
  } 
  
  public void setStartTimeWithDate(String date) {
    String milli =  monthDayYearToMilli(date);
    try {
      Long m = Long.valueOf(milli);  
      startTime = Math.abs(m);  
    } catch (Exception e) {
      e.printStackTrace();
      System.out.println("Failed to Set startTime from dateString.");
    }
  } 
  
  public String getEndTimeMilli() {
    if (endTime != null && endTime > 0) {
      return endTime.toString();
    }
    return null;
  }

    public Long getEndTime() {
        return endTime;
    }
  
  private String monthDayYearToMilli(String newDate) {
    SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
    String month = newDate.substring(0,2);
    String day = newDate.substring(3,5);
    String year = newDate.substring(6,10);
    Date dt;
    try {
      dt = sdf.parse(month+"-"+day+"-"+year);
    } catch (ParseException e) {
      e.printStackTrace();
      System.out.println("Failed to Parse String : "+month+"-"+day+"-"+year);
      return null;
    }
    return String.valueOf(dt.getTime());
  }
  
  private String milliToMonthDayYear(Long millis) {
    if (millis!=null) {
      try {
        DateTime dt = new DateTime(millis);
        DateTimeFormatter dtf = DateTimeFormat.forPattern("yyyy-MM-dd hh:mm a");
        return dtf.print(dt);       
      } catch (Exception e) {
        e.printStackTrace();
      }      
    }
    return null;
  }
  
  public String getStartDateTime() {
    if (startTime!=null) {
      return milliToMonthDayYear(startTime);
    }
    return null;
  }
  
  public String getEndDateTime() {
    if (endTime!=null) {
      return milliToMonthDayYear(endTime);      
    }
    return null;
  }


    //see also getComputedDurationTrackSum() below
    public Long getComputedDuration() {
        if ((startTime == null) || (endTime == null)) return null;
        if (startTime > endTime) {
            System.out.println("ERROR!  getComputedDuration() invalid (" + startTime + " > " + endTime + ") for " + this);
            return null;
        }
        return endTime - startTime;
    }
    //adds up each track duration
    public Long getComputedDurationTrackSum() {
        if (Util.collectionIsEmptyOrNull(surveyTracks)) return null;
        Long sum = 0L;
        for (SurveyTrack st : surveyTracks) {
            if (st == null) continue;  //TODO or return null ????
            Long dur = st.getComputedDuration();
            if (dur == null) return null;  //TODO or continue ???  argument for null: we have a track but it has unknown duration but cant assume 0
            sum += dur;
        }
        return sum;
    }
    //from start of tracks to end of tracks
    public Long getComputedDurationTracks() {
        Long s = getStartTimeTracks();
        Long e = getEndTimeTracks();
        if ((s == null) || (e == null)) return null;
        if (s > e) {
            System.out.println("ERROR!  getComputedDurationTracks() invalid (" + s + " > " + e + ") for " + this);
            return null;
        }
        return e - s;
    }
    public Long getStartTimeTracks() {
        if (Util.collectionIsEmptyOrNull(surveyTracks)) return null;
        Long start = null;
        for (SurveyTrack st : surveyTracks) {
            if (st == null) continue;
            Long t = st.getStartTime();
            if (t == null) continue;
            if ((start == null) || (start > t)) start = t;
        }
        return start;
    }
    public Long getEndTimeTracks() {
        if (Util.collectionIsEmptyOrNull(surveyTracks)) return null;
        Long end = null;
        for (SurveyTrack st : surveyTracks) {
            if (st == null) continue;
            Long t = st.getEndTime();
            if (t == null) continue;
            if ((end == null) || (t > end)) end = t;
        }
        return end;
    }

  public ArrayList<Observation> getObservationArrayList() {
    return observations;
  }

  public void addObservationArrayList(ArrayList<Observation> arr) {
    if (observations.isEmpty()) {
      observations=arr;      
    } else {
     observations.addAll(arr); 
    }
  }
  public void addObservation(Observation obs) {
    observations.add(obs);
  }
  public Observation getObservationByName(String obName) {
    if (observations != null && !observations.isEmpty()) {
      for (Observation ob : observations) {
        if (ob.getName() != null) {
          if (ob.getName().toLowerCase().trim().equals(obName.toLowerCase().trim())) {
            return ob;            
          }
        }
      }
    }
    return null;
  }
  public Observation getObservationByID(String obId) {
    if (observations != null && observations.size() > 0) {
      for (Observation ob : observations) {
        if (ob.getID() != null && ob.getID().equals(obId)) {
          return ob;
        }
      }
    }
    return null;
  }
  public void removeObservation(String name) {
    int counter = 0;
    if (observations != null && observations.size() > 0) {
      for (Observation ob : observations) {
        if (ob.getName() != null) {
          if (ob.getName().toLowerCase().trim().equals(name.toLowerCase().trim())) {
             System.out.println("Match! Trying to delete Observation "+name+" at index "+counter);
             observations.remove(counter);
             break;
          }
        }
        counter++;
      }
    }  
  } 


    public void writeExcel(File xlsFile) throws java.io.IOException, jxl.write.WriteException {
        WritableWorkbook workbook = Workbook.createWorkbook(xlsFile);
        String sheetName = this.getID().substring(0,8);
        WritableSheet sheetSurvey = workbook.createSheet("Survey " + sheetName, 0);
        WritableSheet sheetTracks = workbook.createSheet("Tracks " + sheetName, 1);
        WritableSheet sheetSightings = workbook.createSheet("Sightings " + sheetName, 2);
        WritableSheet sheetPaths = workbook.createSheet("Paths " + sheetName, 3);
        excelHeader(sheetSurvey, new String[]{"ID", "Date", "Created", "Comments", "Project", "Organization", "Start", "End", "Tracks"});
        excelHeader(sheetTracks, new String[]{"ID", "Vessel", "Start", "End", "Duration", "Location ID", "Type", "Path", "Sightings"});
        excelHeader(sheetSightings, new String[]{"ID"});
        //excelHeader(sheetPaths, new String[]{"Track ID", "Path ID", "Points"});
        sheetSurvey.addCell(new Label(0, 1, this.getID()));
        sheetSurvey.addCell(new Label(1, 1, this.getDate()));
        sheetSurvey.addCell(new Label(2, 1, this.getDateTimeCreated()));
        sheetSurvey.addCell(new Label(3, 1, this.getComments()));
        sheetSurvey.addCell(new Label(4, 1, this.getProjectName()));
        sheetSurvey.addCell(new Label(5, 1, this.getOrganization()));
        sheetSurvey.addCell(new Label(6, 1, this.getStartDateTime()));
        sheetSurvey.addCell(new Label(7, 1, this.getEndDateTime()));
        int tct = 0;
        if (!Util.collectionIsEmptyOrNull(this.surveyTracks)) for (SurveyTrack trk : this.surveyTracks) {
            sheetSurvey.addCell(new Label(8 + tct, 1, trk.getID()));
            excelTrack(trk, tct, sheetTracks, sheetSightings, sheetPaths);
            tct++;
        }
        int oct = 0;
        if (!Util.collectionIsEmptyOrNull(this.observations)) for (Observation obs : this.observations) {
            sheetSurvey.addCell(new Label(0, 4 + tct, new DateTime(obs.getDateAddedMilli()).toString()));
            sheetSurvey.addCell(new Label(1, 4 + tct, obs.getName()));
            sheetSurvey.addCell(new Label(2, 4 + tct, obs.getValue()));
            oct++;
        }
        workbook.write();
        workbook.close();
    }

    private void excelHeader(WritableSheet sheet, String[] headers) throws jxl.write.WriteException {
        for (int i = 0 ; i < headers.length ; i++) {
            sheet.addCell(new Label(i, 0, headers[i]));
        }
    }

    private void excelTrack(SurveyTrack trk, int num, WritableSheet sTracks, WritableSheet sSightings, WritableSheet sPaths) throws jxl.write.WriteException {
        sTracks.addCell(new Label(0, num + 1, trk.getID()));
        sTracks.addCell(new Label(1, num + 1, trk.getVesselID()));
        sTracks.addCell(new Label(2, num + 1, new DateTime(trk.getStartTime()).toString()));
        sTracks.addCell(new Label(3, num + 1, new DateTime(trk.getEndTime()).toString()));
        sTracks.addCell(new Label(4, num + 1, Long.toString(trk.getComputedDuration())));
        sTracks.addCell(new Label(5, num + 1, trk.getLocationID()));
        sTracks.addCell(new Label(6, num + 1, trk.getType()));
        if (trk.getPath() != null) {
            sTracks.addCell(new Label(7, num + 1, trk.getPath().getID()));
            List<PointLocation> pts = trk.getPath().getPointLocationsSubsampled();
            if (!Util.collectionIsEmptyOrNull(pts)) {
                sPaths.addCell(new Label(num, 0, trk.getID()));
                sPaths.addCell(new Label(num, 1, trk.getPath().getID()));
                int pct = 0;
                for (PointLocation pt : pts) {
                    sPaths.addCell(new Label(num, pct + 2, Double.toString(pt.getLatitude()) + "," + Double.toString(pt.getLongitude())));
                    pct++;
                }
            }
        }

        int occct = 0;
        if (!Util.collectionIsEmptyOrNull(trk.getOccurrences())) for (Occurrence occ : trk.getOccurrences()) {
            sTracks.addCell(new Label(7 + occct, num + 1, occ.getOccurrenceID()));
            sSightings.addCell(new Label(0, 1 + occct, occ.getOccurrenceID()));
            //TODO make this more content
            occct++;
        }
    }

    public String toString() {
        return new ToStringBuilder(this)
            .append("id", getID())
            .append("type", type)
            .append("tracks", this.numSurveyTracks())
            .append("startTime", new DateTime(startTime))
            .append("endTime", new DateTime(endTime))
            .toString();
    }


}





