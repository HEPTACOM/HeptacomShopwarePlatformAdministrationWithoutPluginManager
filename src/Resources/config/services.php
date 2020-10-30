<?php declare(strict_types=1);

namespace Symfony\Component\DependencyInjection\Loader\Configurator;

use Heptacom\Shopware\Administration\WithoutPluginManager\Api\Controller\Deny;
use Heptacom\Shopware\Administration\WithoutPluginManager\Subscriber\DenyPluginUpdatesViaApi;

return static function (ContainerConfigurator $configurator): void {
    $configurator->services()
        ->set(DenyPluginUpdatesViaApi::class)
        ->args([ref(Deny::class)])
        ->tag('kernel.event_subscriber');

    $configurator->services()
        ->set(Deny::class);
};
