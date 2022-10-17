page 73100 "Test API"
{
    ApplicationArea = All;
    Caption = 'Test API';
    PageType = List;
    SourceTable = "Integer";
    SourceTableView = sorting(Number) where(Number = const(1));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Number; Rec.Number)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Excel row number.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CallAPI)
            {
                Caption = 'Test API';
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    TestAPI: Codeunit "Test API";
                begin
                    TestAPI.BottomLineAuthentication();
                end;
            }
        }
    }
}
