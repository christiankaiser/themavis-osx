//
//  TestController.m
//  ThemaMap
//
//  Created by Christian on 24.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TestController.h"


@implementation TestController


-(IBAction)doTest:(id)sender
{

	// Lire le fichier Shape avec les communes lausannoises
	TMShapefile *lsneCommunes = [[TMShapefile alloc] initWithPath:
		@"/Volumes/Fochur/Programmation/ThemaMap/_data/Lausanne/Ls-Communes.shp"];
	
	TMLayer *lsneCommunesLayer = [lsneCommunes read];
	
	// Créer une vue pour la carte
	NSRect mapViewFrame = NSMakeRect(40, 40, 762, 515);
	TMMapView *mapView = [[TMMapView alloc] initWithFrame:mapViewFrame];
	
	// Définir l'extrait visible de la carte
	TMEnvelope *mapEnv = [[TMEnvelope alloc] init];
	[mapEnv setWest:515000];
	[mapEnv setEast:550000];
	[mapEnv setNorth:170000];
	[mapEnv setSouth:145000];
	[mapView setEnvelope:mapEnv];
	
	// Associer la couche des communes à la vue pour la carte
	[mapView addObjectToLayers:lsneCommunesLayer];
	
	// Créer un style de remplissage pour les communes
	TMFillStyle *lsneFillStyle = [[TMFillStyle alloc] init];
	[lsneFillStyle setFillColor:[NSColor redColor]];
	
	// Associer le style avec la couche
	[lsneCommunesLayer setStyle:lsneFillStyle];
	
	// Ajouter la vue pour la carte à la page
	[_page zoomToAll];
	[_page addSubview:mapView];
	[_page setNeedsDisplay:YES];
		
}


@end
