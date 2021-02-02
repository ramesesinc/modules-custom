[getReceipts]
select 
	c.receiptid, c.controlid, c.formno, c.series, 
	convert(c.receiptdate, date) as receiptdate, c.receiptno, tmp2.amount, 
  ia.title as particulars, c.paidby as payer, c.paidbyaddress as payeraddress 
from ( 
	select receiptid, acctid, sum(amount) as amount 
	from ( 
		select ci.receiptid, ci.acctid, sum(ci.amount) as amount 
		from collectionvoucher cv 
			inner join (
				select distinct maingroupid, itemid 
				from account_item_mapping 
				where maingroupid = 'BFP' 
			)aim on 1=1 
			inner join vw_remittance_cashreceiptitem ci on (ci.collectionvoucherid = cv.objid and ci.acctid = aim.itemid) 
		where cv.controldate >= $P{startdate} 
			and cv.controldate < $P{enddate} 
		group by ci.receiptid, ci.acctid 
		union all 
		select ci.receiptid, ci.refacctid as acctid, -sum(ci.amount) as amount 
		from collectionvoucher cv 
			inner join (
				select distinct maingroupid, itemid 
				from account_item_mapping 
				where maingroupid = 'BFP' 
			)aim on 1=1 
			inner join vw_remittance_cashreceiptshare ci on (ci.collectionvoucherid = cv.objid and ci.refacctid = aim.itemid) 
		where cv.controldate >= $P{startdate} 
			and cv.controldate < $P{enddate} 
		group by ci.receiptid, ci.refacctid 
		union all 
		select ci.receiptid, ci.acctid, sum(ci.amount) as amount 
		from collectionvoucher cv 
			inner join (
				select distinct maingroupid, itemid 
				from account_item_mapping 
				where maingroupid = 'BFP' 
			)aim on 1=1 
			inner join vw_remittance_cashreceiptshare ci on (ci.collectionvoucherid = cv.objid and ci.acctid = aim.itemid) 
		where cv.controldate >= $P{startdate} 
			and cv.controldate < $P{enddate} 
		group by ci.receiptid, ci.acctid 
	)tmp1 
	group by receiptid, acctid
)tmp2  
	inner join vw_remittance_cashreceipt c on c.receiptid = tmp2.receiptid 
	inner join itemaccount ia on ia.objid = tmp2.acctid 
where c.voided = 0 
order by c.formno, convert(c.receiptdate, date), c.series 


[getReceiptsByGroup]
select 
	tmp2.liq_objid, tmp2.liq_controldate, tmp2.liq_controlno, 
	c.receiptid, c.controlid, c.formno, c.series, 
	convert(c.receiptdate, date) as receiptdate, c.receiptno, tmp2.amount, 
  ia.title as particulars, c.paidby as payer, c.paidbyaddress as payeraddress 
from ( 
	select liq_objid, liq_controlno, liq_controldate, receiptid, acctid, sum(amount) as amount 
	from ( 
		select 
			cv.objid as liq_objid, cv.controlno as liq_controlno, 
			convert(cv.controldate, date) as liq_controldate, 
			ci.receiptid, ci.acctid, sum(ci.amount) as amount 
		from collectionvoucher cv 
			inner join (
				select distinct maingroupid, itemid 
				from account_item_mapping 
				where maingroupid = 'BFP' 
			)aim on 1=1 
			inner join vw_remittance_cashreceiptitem ci on (ci.collectionvoucherid = cv.objid and ci.acctid = aim.itemid) 
		where cv.controldate >= $P{startdate} 
			and cv.controldate < $P{enddate} 
		group by 
			cv.objid, cv.controlno, convert(cv.controldate, date), ci.receiptid, ci.acctid 
		union all 
		select 
			cv.objid as liq_objid, cv.controlno as liq_controlno, 
			convert(cv.controldate, date) as liq_controldate, 
			ci.receiptid, ci.refacctid as acctid, -sum(ci.amount) as amount 
		from collectionvoucher cv 
			inner join (
				select distinct maingroupid, itemid 
				from account_item_mapping 
				where maingroupid = 'BFP' 
			)aim on 1=1 
			inner join vw_remittance_cashreceiptshare ci on (ci.collectionvoucherid = cv.objid and ci.refacctid = aim.itemid) 
		where cv.controldate >= $P{startdate} 
			and cv.controldate < $P{enddate} 
		group by 
			cv.objid, cv.controlno, convert(cv.controldate, date), ci.receiptid, ci.refacctid 
		union all 
		select 
			cv.objid as liq_objid, cv.controlno as liq_controlno, 
			convert(cv.controldate, date) as liq_controldate, 
			ci.receiptid, ci.acctid, sum(ci.amount) as amount 
		from collectionvoucher cv 
			inner join (
				select distinct maingroupid, itemid 
				from account_item_mapping 
				where maingroupid = 'BFP' 
			)aim on 1=1 
			inner join vw_remittance_cashreceiptshare ci on (ci.collectionvoucherid = cv.objid and ci.acctid = aim.itemid) 
		where cv.controldate >= $P{startdate} 
			and cv.controldate < $P{enddate} 
		group by 
			cv.objid, cv.controlno, convert(cv.controldate, date), ci.receiptid, ci.acctid 
	)tmp1 
	group by liq_objid, liq_controlno, liq_controldate, receiptid, acctid
)tmp2  
	inner join vw_remittance_cashreceipt c on c.receiptid = tmp2.receiptid 
	inner join itemaccount ia on ia.objid = tmp2.acctid 
where c.voided = 0 
order by tmp2.liq_controldate, tmp2.liq_controlno, convert(c.receiptdate, date), c.series 
