[getReportByLiquidation]
select 
	ia.objid, ia.code, ia.title, 
	ia.fund_objid, ia.fund_title,
	sum(tmp1.amount) as amount 
from ( 
	select aim.maingroupid, ci.acctid, sum(ci.amount) as amount 
	from 
		collectionvoucher cv, vw_remittance_cashreceiptitem ci, 
		(
			select distinct maingroupid, itemid 
			from account_item_mapping 
			where maingroupid = 'BFP' 
		)aim 
	where cv.controldate >= $P{startdate} 
		and cv.controldate < $P{enddate} 
		and ci.collectionvoucherid = cv.objid 
		and ci.acctid = aim.itemid 
		and ci.voided = 0 
	group by aim.maingroupid, ci.acctid 
	union all 
	select aim.maingroupid, ci.refacctid as acctid, -sum(ci.amount) as amount 
	from 
		collectionvoucher cv, vw_remittance_cashreceiptshare ci, 
		(
			select distinct maingroupid, itemid 
			from account_item_mapping 
			where maingroupid = 'BFP' 
		)aim 
	where cv.controldate >= $P{startdate} 
		and cv.controldate < $P{enddate} 
		and ci.collectionvoucherid = cv.objid 
		and ci.refacctid = aim.itemid 
		and ci.voided = 0 
	group by aim.maingroupid, ci.refacctid 
	union all 
	select aim.maingroupid, ci.acctid, sum(ci.amount) as amount 
	from 
		collectionvoucher cv, vw_remittance_cashreceiptshare ci, 
		(
			select distinct maingroupid, itemid 
			from account_item_mapping 
			where maingroupid = 'BFP' 
		)aim 
	where cv.controldate >= $P{startdate} 
		and cv.controldate < $P{enddate} 
		and ci.collectionvoucherid = cv.objid 
		and ci.acctid = aim.itemid 
		and ci.voided = 0 
	group by aim.maingroupid, ci.acctid 
)tmp1 
	inner join itemaccount ia on ia.objid = tmp1.acctid 
	inner join fund on fund.objid = ia.fund_objid 
group by 
	ia.objid, ia.code, ia.title, 
	ia.fund_objid, ia.fund_title 
order by ia.fund_title, ia.code, ia.title 
