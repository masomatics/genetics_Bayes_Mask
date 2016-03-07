med_ARD = median(rmse_ARD(:));
figure(1)
set(gca,'FontName','Helvetica','FontSize',20);
%plot(ones(N_dataset,1),S_FAB(2,:,n1),'ob','LineWidth',1);
plot([0.5 3.5],med_ARD.*[1 1],'g','LineWidth',2)
hold on
%plot(2*ones(N_dataset,1),S_ARD(2,:,n1),'ob','LineWidth',1);
boxplot([rmse_BM, rmse_Lasso, rmse_ARD]);
hold off
xlabel('Method');
ylabel('RMSE');
xlim([0.5 3.5]);
%ylim([0.9,1.1]);
set(gca,'XTickLabel',{'BM';'Lasso';'ARD'},'XTick',1:3);
pbaspect([1,1,1])
fname = sprintf('Generalization_error_RMSE_K%d.eps',K);
saveas(figure(1),fname,'epsc2');
