package bfp.treasury.report.models;

import com.rameses.rcp.common.*;
import com.rameses.rcp.annotations.*;
import com.rameses.osiris2.client.*;
import com.rameses.osiris2.reports.*;

class CollectionReportModel extends AsyncReportController {

    @Script('ReportPeriod') 
    def periodUtil; 
    
    @Script('User') 
    def user;    

    @Service('BFPCollectionReportService') 
    def svc;
    
    String title = 'Report of Collections (BFP)';
    String reportPath =  "bfp/treasury/report/jasper/";
    
    def data;
    def param = [:];
    def reportParam = [:]; 
   
    def templateTypes = [
        [objid: 'default', name: 'Default Template', report: 'collection.jasper'],
        [objid: 'liquidation_group', name: 'Group By Liquidation', report: 'collection_liquidation_group.jasper']
    ]; 
        
    def postingTypes = [
        [objid: 'liquidation', name: 'By Liquidation Date']
    ]; 
        
    def initReport() { 
        def outcome = super.initReport(); 

        def res = svc.init([:]); 
        entity.template = templateTypes[0]; 
        entity.period = periodUtil.types.find{( it.type == 'monthly' )}?.type; 
        return outcome; 
    }
    
    String getReportName() { 
        return reportPath + entity.template?.report; 
    }
    
    void buildReportData(entity, asyncHandler) { 
        def m = periodUtil.build( entity.period, entity ); 
        
        reportParam.clear(); 
        reportParam.PERIOD_TITLE = buildPeriodTitle( entity.period, m.startdate, m.enddate ); 
        reportParam.PREPAREDBY_NAME = user.env.FULLNAME; 
        reportParam.PREPAREDBY_TITLE = user.env.JOBTITLE; 
        
        def dateBean = new com.rameses.util.DateBean( m.enddate ); 
        m.enddate = periodUtil.format( dateBean.add("1d"), 'yyyy-MM-dd' ); 
        
        entity.enddate = m.enddate; 
        entity.startdate = m.startdate;
        svc.getReport(entity, asyncHandler);
        param.clear(); 
    } 

    Map getParameters() { 
        return reportParam; 
    } 


    
    private String buildPeriodTitle( period, startdate, enddate ) { 
        def type = period.toString(); 
        startdate = toDate( startdate ); 
        enddate = toDate( enddate ); 
        
        if ( type == 'yearly' ) {
            def buff = new StringBuilder(); 
            buff.append( periodUtil.format( startdate, 'MMMMM' )).append(' - '); 
            buff.append( periodUtil.format( enddate, 'MMMMM, yyyy' )); 
            return buff.toString().toUpperCase(); 
        }
        else if ( type == 'quarterly' ) {
            def buff = new StringBuilder(); 
            buff.append( periodUtil.format( startdate, 'MMMMM' )).append(' - '); 
            buff.append( periodUtil.format( enddate, 'MMMMM, yyyy' )); 
            return buff.toString().toUpperCase(); 
        }
        else if ( type == 'monthly' ) {
            return periodUtil.format( startdate, 'MMMMM yyyy' ).toUpperCase();  
        }
        else if ( type == 'daily' ) {
            return periodUtil.format( startdate, 'MMMMM dd, yyyy' ).toUpperCase();  
        }
        else if ( type == 'range' ) {
            def buff = new StringBuilder(); 
            buff.append( periodUtil.format( startdate, 'MMM/dd/yyyy' )).append(' - '); 
            buff.append( periodUtil.format( enddate, 'MMM/dd/yyyy' )); 
            return buff.toString().toUpperCase(); 
        }
        return null; 
    } 
    
    private def toDate( value ) {
        if ( !value ) return null; 
        if ( value instanceof java.util.Date ) return value; 
        
        try {
            return java.sql.Timestamp.valueOf( value ); 
        } catch(Throwable t) {;} 

        try {
            return java.sql.Date.valueOf( value ); 
        } catch(Throwable t) {
            return null; 
        } 
    }
}