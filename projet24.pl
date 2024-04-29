% Souhail Daoudi
% 300135458

% dataset(DirectoryName)
% this is where the image dataset is located
dataset('C:\\Users\\Documents\\imageDataset2_15_20\\').

% directory_textfiles(DirectoryName, ListOfTextfiles)
% produces the list of text files in a directory
directory_textfiles(D,Textfiles):- directory_files(D,Files), include(isTextFile, Files, Textfiles).
isTextFile(Filename):-string_concat(_,'.txt',Filename).


% read_hist_file(Filename,ListOfNumbers)
% reads a histogram file and produces a list of numbers (bin values)
read_hist_file(Filename,Numbers):- open(Filename,read,Stream),read_line_to_string(Stream,_),
                                   read_line_to_string(Stream,String), close(Stream),
								   atomic_list_concat(List, ' ', String),atoms_numbers(List,Numbers).
								   
% similarity_search(QueryFile,SimilarImageList)
% returns the list of images similar to the query image
% similar images are specified as (ImageName, SimilarityScore)
% predicat dataset/1 provides the location of the image set
similarity_search(QueryFile,SimilarList) :- dataset(D), directory_textfiles(D,TxtFiles),
                                            similarity_search(QueryFile,D,TxtFiles,SimilarList).


% similarity_search(QueryFile, DatasetDirectory, HistoFileList, SimilarImageList)
similarity_search(QueryFile,DatasetDirectory, DatasetFiles,Best):- read_hist_file(QueryFile,QueryHisto), 
                                            compare_histograms(QueryHisto, DatasetDirectory, DatasetFiles, Scores), 
                                            sort(2,@>,Scores,Sorted),take(Sorted,5,Best).


% compare_histograms(QueryHisto,DatasetDirectory,DatasetFiles,Scores)
% compares a query histogram with a list of histogram files 
% R represent datasetfile , Sum is the sum of a histogram , Scores containt liste of datafilenames and their compared histograms 
compare_histograms(_,_,[],[]).
compare_histograms(QueryHisto,DatasetDirectory,[R|DatasetFiles],[(R,Sum)|Scores]):-  read_hist_file( R ,DataHisto),
                                                                                     normalize(QueryHisto,QueryHistoNormalized),normalize(DataHisto,DataHistoNormalized),
                                                                                     histogram_intersection(QueryHistoNormalized, DataHistoNormalized,HistoCompared),
                                                                                     somme(HistoCompared,Sum) ,compare_histograms(QueryHisto,DatasetDirectory,DatasetFiles,Scores).



% compute sum of histogram , somme(HistoCompared,Sum)
somme(L,S) :- somme(L,0,S).
              somme([X|L],T,S) :- TT is T+X, somme(L,TT,S).
              somme([],S,S).


% normalize query and data histograms , normalize(Histo , HistoNormalized)
normalize([],[]).
normalize([Y|Histo],[Z|HistoNormalized]):- Z is Y/172800 , normalize(Histo,HistoNormalized).



% histogram_intersection(Histogram1, Histogram2, Score)
% compute the intersection similarity score between two histograms
% Score is between 0.0 and 1.0 (1.0 for identical histograms)
histogram_intersection([],[],[]).
histogram_intersection([X|H1],[Y|H2],[X|S]):- X<Y ,histogram_intersection(H1,H2,S ).
histogram_intersection([X|H1],[Y|H2],[Y|S]):- Y =< X ,histogram_intersection( H1,H2,S ).


% take(List,K,KList)
% extracts the K first items in a list
take(Src,N,L) :- findall(E, (nth1(I,Src,E), I =< N), L).


% atoms_numbers(ListOfAtoms,ListOfNumbers)
% converts a list of atoms into a list of numbers
atoms_numbers([],[]).
atoms_numbers([X|L],[Y|T]):- atom_number(X,Y), atoms_numbers(L,T).
atoms_numbers([X|L],T):- \+atom_number(X,_), atoms_numbers(L,T).
