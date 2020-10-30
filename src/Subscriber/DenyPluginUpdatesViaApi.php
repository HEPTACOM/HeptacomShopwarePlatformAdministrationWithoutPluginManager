<?php declare(strict_types=1);

namespace Heptacom\Shopware\Administration\WithoutPluginManager\Subscriber;

use Heptacom\Shopware\Administration\WithoutPluginManager\Api\Controller\Deny;
use Shopware\Core\Framework\Routing\KernelListenerPriorities;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ControllerEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class DenyPluginUpdatesViaApi implements EventSubscriberInterface
{
    public const PLUGIN_API_ROUTES = [
        'api.action.plugin.upload',
        'api.action.plugin.delete',
        'api.action.plugin.install',
        'api.action.plugin.uninstall',
        'api.action.plugin.activate',
        'api.action.plugin.deactivate',
        'api.action.plugin.update',
    ];

    /**
     * @var Deny
     */
    private $deny;

    public function __construct(Deny $deny)
    {
        $this->deny = $deny;
    }

    public static function getSubscribedEvents()
    {
        return [
            KernelEvents::CONTROLLER => [[
                'onDenyRequest', KernelListenerPriorities::KERNEL_CONTROLLER_EVENT_PRIORITY_AUTH_VALIDATE_POST,
            ]],
        ];
    }

    public function onDenyRequest(ControllerEvent $event): void
    {
        if (!\in_array($event->getRequest()->attributes->get('_route', ''), self::PLUGIN_API_ROUTES, true)) {
            return;
        }

        $event->setController([$this->deny, 'deny']);
    }
}
