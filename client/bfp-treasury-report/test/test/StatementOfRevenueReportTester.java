/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package test;

import com.rameses.service.ScriptServiceContext;
import java.util.HashMap;
import java.util.Map;
import junit.framework.TestCase;

/**
 *
 * @author ramesesinc
 */
public class StatementOfRevenueReportTester extends TestCase {
    
    private final String BIN         = "B15420161103102";
    
    private final String APP_HOST    = "localhost:18070"; 
    private final String APP_CLUSTER = "osiris3"; 
    private final String APP_CONTEXT = "etracs25"; 
    
    private ScriptServiceContext ctx; 
    private Map env; 
    
    public StatementOfRevenueReportTester(String testName) {
        super(testName);
    }

    protected void setUp() throws Exception {
        Map appenv = new HashMap();
        appenv.put("app.host", APP_HOST);
        appenv.put("app.cluster", APP_CLUSTER);
        appenv.put("app.context", APP_CONTEXT);
        
        ctx = new ScriptServiceContext(appenv);   
        
        env = new HashMap();
    }
    
    public void testRenewal() throws Exception {

        Map param = new HashMap();
        param.put("startdate", "2020-01-01"); 
        param.put("enddate", "2020-02-01"); 

        IService svc = ctx.create("BFPStatementOfRevenueReportService", env, IService.class);        
        Object res = svc.getReport( param ); 
        System.out.println( res );
    }
        
    public interface IService {
        Object getReport( Map param );
    } 
}
