package bfp.treasury.report.models;

import com.rameses.rcp.common.*;
import com.rameses.rcp.annotations.*;
import com.rameses.osiris2.client.*;
import com.rameses.osiris2.reports.*;

class StatementOfRevenueReportModel extends AsyncReportController {

    @Script('ReportPeriod') 
    def periodUtil; 

    @Service('BFPStatementOfRevenueReportService') 
    def svc;
    
    String title = 'Statement of Revenue (BFP)';
    String reportpath =  "bfp/treasury/report/jasper/";
    String reportName = reportpath + 'revenueitem.jasper';
    
    def data;
    def param = [:];
   
    def postingTypes = [
        [objid: 'liquidation', name: 'By Liquidation Date']
    ]; 
        
    def initReport() { 
        def outcome = super.initReport(); 

        def res = svc.init([:]); 
        entity.period = periodUtil.types.find{( it.type == 'monthly' )}?.type; 
        return outcome; 
    }
    
    void buildReportData(entity, asyncHandler) { 
        def m = periodUtil.build( entity.period, entity ); 
        def dateBean = new com.rameses.util.DateBean( m.enddate ); 
        m.enddate = periodUtil.format( dateBean.add("1d"), 'yyyy-MM-dd' ); 
        
        entity.enddate = m.enddate; 
        entity.startdate = m.startdate;
        svc.getReport(entity, asyncHandler);
        param.clear(); 
    } 

    Map getParameters() { 
        param.PERIOD = buildPeriodTitle(); 
        return param;
    } 
    
    private def formatter_1 = new java.text.SimpleDateFormat('MMMMM dd, yyyy');
    
    private String buildPeriodTitle() { 
        def type = entity.period.toString(); 
        if ( type == 'yearly' ) {
            return 'FOR THE YEAR '+ entity.year; 
        }
        else if ( type == 'quarterly' ) {
            return 'FOR THE YEAR '+ entity.year +' - Q'+ entity.qtr; 
        }
        else if ( type == 'monthly' ) {
            return ('FOR THE MONTH OF '+ entity.month?.caption +' '+ entity.year).toUpperCase(); 
        }
        else if ( type == 'daily' ) {
            return formatter_1.format( entity.date ).toUpperCase(); 
        }
        else if ( type == 'range' ) {
            def buff = new StringBuilder(); 
            buff.append( formatter_1.format( entity.startdate ) ).append(" - "); 
            buff.append( formatter_1.format( entity.enddate ) );
            return buff.toString().toUpperCase(); 
        }
        return null; 
    } 
}