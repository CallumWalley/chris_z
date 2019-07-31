
n [DATA] = AutomateRun(row, file)
    tic
    inputObject = matfile(file);
    DATA=inputObject.DATA(1,row);
    toc
    %% calling the main function
    [LinkBID, LinkASK, RunsBid, RunsAsk] = StrategicRuns_v2(DATA);
    %% repeat the above algorithm with RunsBid & RunsAsk
    % 1. First make the structure and the field name of RunsBid & RunsAsk
    %    consistent with the LinkBID & LinkASK
    [RunsBid.Linked_Messages] = RunsBid.LinkedMessages; RunsBid = orderfields(RunsBid,[1:1,3,2:2]); RunsBid = rmfield(RunsBid,'LinkedMessages');
    [RunsAsk.Linked_Messages] = RunsAsk.LinkedMessages; RunsAsk = orderfields(RunsAsk,[1:1,3,2:2]); RunsAsk = rmfield(RunsAsk,'LinkedMessages');
    [LinkBID, LinkASK] = roload(DATA);
    %%
    B=[];
    for s=1:length(RunsBid)
        L=RunsBid(s).Linked_Messages;
        top=L(1);
        B=[B;top];
    end
    BB=[];
    for s=1:length(LinkBID)
        L=LinkBID(s).Linked_Messages;
        Top=L(1);
        BB=[BB;Top];
    end
    COORDINATE=[];
    for j=1:length(B)
        coordinate=find(BB(:,1)==B(j));
        COORDINATE=[COORDINATE;coordinate];
    end
    % merge BidID into RunsBid
    for p=1:length(RunsBid)
        coor=COORDINATE(p);
        RunsBid(p).BidID=LinkBID(coor).BidID;
    end
    %% Ask side
    B=[];
    for s=1:length(RunsAsk)
        L=RunsAsk(s).Linked_Messages;
        top=L(1);
        B=[B;top];
    end
    BB=[];
    for s=1:length(LinkASK)
        L=LinkASK(s).Linked_Messages;
        Top=L(1);
        BB=[BB;Top];
    end
    COORDINATE=[];
    for j=1:length(B)
        coordinate=find(BB(:,1)==B(j));
        COORDINATE=[COORDINATE;coordinate];
    end
    % merge BidID into RunsBid
    for p=1:length(RunsAsk)
        coor=COORDINATE(p);
        RunsAsk(p).AskID=LinkASK(coor).AskID;
    end
    %% 2. Identify how many inferred links does each row contain
    % BID SIDE
    numlink=[];
    for k=1:length(RunsBid)
        linkedmessages=RunsBid(k).Linked_Messages;
        bidid=DATA(1).BID_ID;
        BIDID=[];
        for j=1:length(linkedmessages)
            bid=bidid(linkedmessages(j));
            BIDID=[BIDID;bid];
        end
        num=length(unique(BIDID));
        numlink=[numlink;num];
    end
    if length(numlink)==length(RunsBid)
        for z=1:length(RunsBid)
            RunsBid(z).numlink=numlink(z);
        end
    end
    % ASK SIDE
    numlink=[];
    for k=1:length(RunsAsk)
        linkedmessages=RunsAsk(k).Linked_Messages;
        askid=DATA(1).ASK_ID;
        ASKID=[];
        for j=1:length(linkedmessages)
            ask=askid(linkedmessages(j));
            ASKID=[ASKID;ask];
        end
        num=length(unique(ASKID));
        numlink=[numlink;num];
    end
    if length(numlink)==length(RunsAsk)
        for z=1:length(RunsAsk)
            RunsAsk(z).numlink=numlink(z);
        end
    end
    %% clear redundant variables;
    clearvars -except DATA RunsAsk RunsBid row;
    %% 3. change the name of RunsBid to LinkBID and RunsAsk to LinkASK
    LinkBID = RunsBid; LinkASK = RunsAsk;
    clearvars RunsAsk RunsBid;
    %% 4. run the second stage run filter
    [RunsBid, RunsAsk] = RunSecondStage_v2(DATA, LinkBID, LinkASK);
    %%
    while ((length(LinkASK)-length(RunsAsk)~=1) || (length(LinkBID)-length(RunsBid)~=1))
        %% repeat the above algorithm with RunsBid & RunsAsk
        % 1. First make the structure and the field name of RunsBid & RunsAsk
        %    consistent with the LinkBID & LinkASK
        [RunsBid.Linked_Messages] = RunsBid.LinkedMessages; RunsBid = orderfields(RunsBid,[1:1,3,2:2]); RunsBid = rmfield(RunsBid,'LinkedMessages');
        [RunsAsk.Linked_Messages] = RunsAsk.LinkedMessages; RunsAsk = orderfields(RunsAsk,[1:1,3,2:2]); RunsAsk = rmfield(RunsAsk,'LinkedMessages');
        [LinkBID, LinkASK] = roload(DATA);
        %%
        B=[];
        for s=1:length(RunsBid)
            L=RunsBid(s).Linked_Messages;
            top=L(1);
            B=[B;top];
        end
        BB=[];
        for s=1:length(LinkBID)
            L=LinkBID(s).Linked_Messages;
            Top=L(1);
            BB=[BB;Top];
        end
        COORDINATE=[];
        for j=1:length(B)
            coordinate=find(BB(:,1)==B(j));
            COORDINATE=[COORDINATE;coordinate];
        end
        % merge BidID into RunsBid
        for p=1:length(RunsBid)
            coor=COORDINATE(p);
            RunsBid(p).BidID=LinkBID(coor).BidID;
        end
        %% Ask side
        B=[];
        for s=1:length(RunsAsk)
            L=RunsAsk(s).Linked_Messages;
            top=L(1);
            B=[B;top];
        end
        BB=[];
        for s=1:length(LinkASK)
            L=LinkASK(s).Linked_Messages;
            Top=L(1);
            BB=[BB;Top];
        end
        COORDINATE=[];
        for j=1:length(B)
            coordinate=find(BB(:,1)==B(j));
            COORDINATE=[COORDINATE;coordinate];
        end
        % merge BidID into RunsBid
        for p=1:length(RunsAsk)
            coor=COORDINATE(p);
            RunsAsk(p).AskID=LinkASK(coor).AskID;
        end
        %% 2. Identify how many inferred links does each row contain
        % BID SIDE
        numlink=[];
        for k=1:length(RunsBid)
            linkedmessages=RunsBid(k).Linked_Messages;
            bidid=DATA(1).BID_ID;
            BIDID=[];
            for j=1:length(linkedmessages)
                bid=bidid(linkedmessages(j));
                BIDID=[BIDID;bid];
            end
            num=length(unique(BIDID));
            numlink=[numlink;num];
        end
        if length(numlink)==length(RunsBid)
            for z=1:length(RunsBid)
                RunsBid(z).numlink=numlink(z);
            end
        end
        % ASK SIDE
        numlink=[];
        for k=1:length(RunsAsk)
            linkedmessages=RunsAsk(k).Linked_Messages;
            askid=DATA(1).ASK_ID;
            ASKID=[];
            for j=1:length(linkedmessages)
                ask=askid(linkedmessages(j));
                ASKID=[ASKID;ask];
            end
            num=length(unique(ASKID));
            numlink=[numlink;num];
        end
        if length(numlink)==length(RunsAsk)
            for z=1:length(RunsAsk)
                RunsAsk(z).numlink=numlink(z);
            end
        end
        %% clear redundant variables;
        clearvars -except DATA RunsAsk RunsBid row;
        %% 3. change the name of RunsBid to LinkBID and RunsAsk to LinkASK
        LinkBID = RunsBid; LinkASK = RunsAsk;
        clearvars RunsAsk RunsBid;
        %% 4. keep running the second stage run filter
        [RunsBid, RunsAsk] = RunSecondStage_v2(DATA, LinkBID, LinkASK);
    end
    %% this is the time to trigger the finalstage run;
    [RunsBid, RunsAsk] = RunFinalStage_v2(DATA, LinkBID, LinkASK);
    while ((length(LinkASK)-length(RunsAsk)~=1) || (length(LinkBID)-length(RunsBid)~=1))
        %% repeat the above algorithm with RunsBid & RunsAsk
        % 1. First make the structure and the field name of RunsBid & RunsAsk
        %    consistent with the LinkBID & LinkASK
        [RunsBid.Linked_Messages] = RunsBid.LinkedMessages; RunsBid = orderfields(RunsBid,[1:1,3,2:2]); RunsBid = rmfield(RunsBid,'LinkedMessages');
        [RunsAsk.Linked_Messages] = RunsAsk.LinkedMessages; RunsAsk = orderfields(RunsAsk,[1:1,3,2:2]); RunsAsk = rmfield(RunsAsk,'LinkedMessages');
        [LinkBID, LinkASK] = roload(DATA);
        %%
        B=[];
        for s=1:length(RunsBid)
            L=RunsBid(s).Linked_Messages;
            top=L(1);
            B=[B;top];
        end
        BB=[];
        for s=1:length(LinkBID)
            L=LinkBID(s).Linked_Messages;
            Top=L(1);
            BB=[BB;Top];
        end
        COORDINATE=[];
        for j=1:length(B)
            coordinate=find(BB(:,1)==B(j));
            COORDINATE=[COORDINATE;coordinate];
        end
        % merge BidID into RunsBid
        for p=1:length(RunsBid)
            coor=COORDINATE(p);
            RunsBid(p).BidID=LinkBID(coor).BidID;
        end
        %% Ask side
        B=[];
        for s=1:length(RunsAsk)
            L=RunsAsk(s).Linked_Messages;
            top=L(1);
            B=[B;top];
        end
        BB=[];
        for s=1:length(LinkASK)
            L=LinkASK(s).Linked_Messages;
            Top=L(1);
            BB=[BB;Top];
        end
        COORDINATE=[];
        for j=1:length(B)
            coordinate=find(BB(:,1)==B(j));
            COORDINATE=[COORDINATE;coordinate];
        end
        % merge BidID into RunsBid
        for p=1:length(RunsAsk)
            coor=COORDINATE(p);
            RunsAsk(p).AskID=LinkASK(coor).AskID;
        end
        %% 2. Identify how many inferred links does each row contain
        % BID SIDE
        numlink=[];
        for k=1:length(RunsBid)
            linkedmessages=RunsBid(k).Linked_Messages;
            bidid=DATA(1).BID_ID;
            BIDID=[];
            for j=1:length(linkedmessages)
                bid=bidid(linkedmessages(j));
                BIDID=[BIDID;bid];
            end
            num=length(unique(BIDID));
            numlink=[numlink;num];
        end
        if length(numlink)==length(RunsBid)
            for z=1:length(RunsBid)
                RunsBid(z).numlink=numlink(z);
            end
        end
        % ASK SIDE
        numlink=[];
        for k=1:length(RunsAsk)
            linkedmessages=RunsAsk(k).Linked_Messages;
            askid=DATA(1).ASK_ID;
            ASKID=[];
            for j=1:length(linkedmessages)
                ask=askid(linkedmessages(j));
                ASKID=[ASKID;ask];
            end
            num=length(unique(ASKID));
            numlink=[numlink;num];
        end
        if length(numlink)==length(RunsAsk)
            for z=1:length(RunsAsk)
                RunsAsk(z).numlink=numlink(z);
            end
        end
        %% clear redundant variables;
        clearvars -except DATA RunsAsk RunsBid row;
        %% 3. change the name of RunsBid to LinkBID and RunsAsk to LinkASK
        LinkBID = RunsBid; LinkASK = RunsAsk;
        clearvars RunsAsk RunsBid;
        %% 4. keep running the final stage run filter
        [RunsBid, RunsAsk] = RunFinalStage_v2(DATA, LinkBID, LinkASK);
    end
    % get indicator of whether each row belongs to a LLorders;
        [RunsBid.Linked_Messages] = RunsBid.LinkedMessages; RunsBid = orderfields(RunsBid,[1:1,3,2:2]); RunsBid = rmfield(RunsBid,'LinkedMessages');
        [RunsAsk.Linked_Messages] = RunsAsk.LinkedMessages; RunsAsk = orderfields(RunsAsk,[1:1,3,2:2]); RunsAsk = rmfield(RunsAsk,'LinkedMessages');
        [LinkBID, LinkASK] = roload(DATA);
        %%
        B=[];
        for s=1:length(RunsBid)
            L=RunsBid(s).Linked_Messages;
            top=L(1);
            B=[B;top];
        end
        BB=[];
        for s=1:length(LinkBID)
            L=LinkBID(s).Linked_Messages;
            Top=L(1);
            BB=[BB;Top];
        end
        COORDINATE=[];
        for j=1:length(B)
            coordinate=find(BB(:,1)==B(j));
            COORDINATE=[COORDINATE;coordinate];
        end
        % merge BidID into RunsBid
        for p=1:length(RunsBid)
            coor=COORDINATE(p);
            RunsBid(p).BidID=LinkBID(coor).BidID;
        end
        %% Ask side
        B=[];
        for s=1:length(RunsAsk)
            L=RunsAsk(s).Linked_Messages;
            top=L(1);
            B=[B;top];
        end
        BB=[];
        for s=1:length(LinkASK)
            L=LinkASK(s).Linked_Messages;
            Top=L(1);
            BB=[BB;Top];
        end
        COORDINATE=[];
        for j=1:length(B)
            coordinate=find(BB(:,1)==B(j));
            COORDINATE=[COORDINATE;coordinate];
        end
        % merge BidID into RunsBid
        for p=1:length(RunsAsk)
            coor=COORDINATE(p);
            RunsAsk(p).AskID=LinkASK(coor).AskID;
        end
        %% 2. Identify how many inferred links does each row contain
        % BID SIDE
        numlink=[];
        for k=1:length(RunsBid)
            linkedmessages=RunsBid(k).Linked_Messages;
            bidid=DATA(1).BID_ID;
            BIDID=[];
            for j=1:length(linkedmessages)
                bid=bidid(linkedmessages(j));
                BIDID=[BIDID;bid];
            end
            num=length(unique(BIDID));
            numlink=[numlink;num];
        end
        if length(numlink)==length(RunsBid)
            for z=1:length(RunsBid)
                RunsBid(z).numlink=numlink(z);
            end
        end
        % ASK SIDE
        numlink=[];
        for k=1:length(RunsAsk)
            linkedmessages=RunsAsk(k).Linked_Messages;
            askid=DATA(1).ASK_ID;
            ASKID=[];
            for j=1:length(linkedmessages)
                ask=askid(linkedmessages(j));
                ASKID=[ASKID;ask];
            end
            num=length(unique(ASKID));
            numlink=[numlink;num];
        end
        if length(numlink)==length(RunsAsk)
            for z=1:length(RunsAsk)
                RunsAsk(z).numlink=numlink(z);
            end
        end
    %%
    % now save linked messgaes into DATA;
        DATA.RunsAsk=RunsAsk;
        DATA.RunsBid=RunsBid;
end
