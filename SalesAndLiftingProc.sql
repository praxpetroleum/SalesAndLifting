CREATE PROCEDURE SALES_AND_LIFTING   
@startdate varchar(50),  
@enddate varchar(50)      
AS  
SELECT rc.ID [COLLECTION ID],  
                        vrn.ID [Release No ID],  
                        CASE sor.IsNoInvoice  
                            WHEN 1 THEN 'NO INVOICE'  
                         ELSE (  
                       CASE sor.IsCancelled  
                                    WHEN 1 THEN 'CANCELLED'  
                           ELSE 'ORDER'  
                       END  
                            )  
                        END [STATUS],  
                        ISNULL(dm.Name, 'BUNKER') [DELIVERY METHOD],  
                        bunker.Name [BUNKER],  
                        vrn.ReleaseNoDate [DATE RELEASED],  
                        vrn.LiftingDate [LIFTING DATE],   
                        vrn.Quantity [QTY RELEASED] ,  
                        vrn.OrderReturnID [ORDER NO],  
                        vrn.BunkerTransferID [BUNKER NO],   
                        ISNULL(liftingWarehouse.Name, releaseWarehouse.Name + ' *') WAREHOUSE,  
                        vrn.ReleaseNo [RELEASE NO],  
                        vrn.Companyname [COMPANY],  
                        vrn.[State of use],   
                        vrn.[Industry],  
                        DATEADD(dd, DATEDIFF(dd, 0, [DATE COLLECTED]), 0) [DATE COLLECTED],  
                        ISNULL(i.sopicl_InvoiceCreditQuantity,0) [INVOICED QTY],  
                        [MEASURED LITRES] [WAREHOUSE INVOICED],  
                        rc.wh_measured [MEASURED LITRES],  
                        rc.[STANDARD LITRES],  
                        rc.[NET WEIGHT],  
                        CASE sor.bStandard when 1 then 'STD' else 'MSD' end [LIFT TYPE],  
                        rc.[WAREHOUSE REF],  
                        rc.[TANK NO],  
                        rc.[PRODUCT NAME],   
                        vrn.[HAULIER],  
                        rc.[VEHICLE REG],   
                        rc.[CONSIGNEE],  
                        p.Name [SORAX PRODUCT],  
                        sor.[MMSORderNo],  
                        sor.ParentOrderNo [PARENT NO],  
                        CASE dm.DeliveryTypeId  
                         WHEN 6 THEN 'BUNKER'   
                         ELSE   
                                CASE ISNULL(vrn.ContractID,0)   
                                    WHEN 0 THEN 'SPOT'   
                                    ELSE 'CONTRACT'   
                                END  
                        END [SALE TYPE],    
                        rc.[Warehouse Ref] AS [DOC NUM],  
                        CASE vrn.bCancelled WHEN 1 THEN 'YES' ELSE 'NO' END [RELEASE CANCELLED],  
                        vrn.ContractID [CONTRACT ID],  
                        cust.SiteReference [SITE REFERENCE]  
                    FROM  dbo.vewReleaseNo vrn --ON v.ID = rn.ID   
                        LEFT JOIN dbo.tblSorexReleaseCollection rc ON rc.ReleaseNoID = vrn.ID  
                        LEFT JOIN dbo.tblSorexwarehouse liftingWarehouse ON  liftingWarehouse.WarehouseID = rc.WarehouseID   
                        LEFT JOIN dbo.tblsorexwarehouse releaseWarehouse ON releaseWarehouse.WareHouseID = vrn.WarehouseID  
                        LEFT JOIN dbo.tblSorexDeliveryMethod dm ON dm.DeliveryTypeID = vrn.DeliveryMethodId  
                        LEFT JOIN dbo.tblSorexStockItemextended p ON p.ItemID = vrn.ProductID   
                        LEFT JOIN dbo.tblSorexorderreturn sor ON sor.orderreturnid = vrn.orderreturnid   
         LEFT JOIN dbo.tblSorexWarehouse bunker ON bunker.WareHouseID = vrn.WarehouseToID  
         LEFT JOIN dbo.vewCreditLinesForOrder i ON i.sorl_OrderReturnLineID = vrn.OrderReturnLineID  
                        LEFT JOIN dbo.tblSorexCustomer cust  ON cust.CustId = sor.CustomerID  
  
                    WHERE 1=1 and sor.IsContract=0 and rc.[Date Collected] between CAST(@startdate - 2 as SmallDateTime) and CAST(@enddate - 2 as SmallDateTime)