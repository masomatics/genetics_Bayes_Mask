ge = zeros(N_SEED,1);
for s = 1:N_SEED
    range = (1+(s-1)*(N_SEED-1)):(s*(N_SEED-1));
    ge(s) = mean(rmse_BM(range));
end

figure(1)
set(gca,'FontName','Helvetica','FontSize',20);
plot(prec_BM(:,1),ge,'o','MarkerSize',10)

xlabel('Precision');
ylabel('RMSE');
%xlim([0.5 3.5]);
%ylim([0.9,1.1]);
fname = sprintf('GS_VS_Precision.eps');
saveas(figure(1),fname,'epsc2');

figure(2)
set(gca,'FontName','Helvetica','FontSize',20);
plot(recall_BM(:,1),ge,'o','MarkerSize',10)
xlabel('Recall');
ylabel('RMSE');
%xlim([0.5 3.5]);
%ylim([0.9,1.1]);
fname = sprintf('GS_VS_Recall.eps');
saveas(figure(2),fname,'epsc2');